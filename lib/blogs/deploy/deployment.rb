require "fileutils"
require "aws-sdk-core"
require "rjgit"

require_relative "env"
require_relative "event_loader"

module BLOGS
  module Deploy
    class Deployment
      include FileUtils
      include RJGit

      SSH_KEY_SOURCE = { bucket: S3_BUCKET, key: "key" }
      KNOWN_HOSTS_SOURCE = { bucket: S3_BUCKET, key: "known_hosts" }
      REPO_URL = "git@github.com:blogsed/blogsed.github.io"

      SSH_KEY_PATH = "/tmp/ssh"
      KNOWN_HOSTS_PATH = "/tmp/known_hosts"
      REPO_PATH = "/tmp/clone"

      FACEBOOK_ACCESS_TOKEN = ENV.fetch("FACEBOOK_ACCESS_TOKEN")
      PAGE_ID = ENV.fetch("PAGE_ID")

      COMMITTER_NAME = "The BLOGS Deployment Robot"
      COMMITTER_EMAIL = "deploy@blogs.org.uk"
      COMMIT_MESSAGE = "Include auto-generated content"
      REMOTE_NAME = "origin"
      REMOTE_BRANCH = "master"

      REPO = Repo.new(REPO_PATH)
      HEAD = REPO.head
      COMMITTER = Actor.new(COMMITTER_NAME, COMMITTER_EMAIL)
      TARGET_REF = "refs/heads/#{REMOTE_BRANCH}"
      GIT_TRANSPORT_OPTIONS = {
        private_key_file: SSH_KEY_PATH,
        known_hosts_file: KNOWN_HOSTS_PATH,
      }
      PUSH_OPTIONS = GIT_TRANSPORT_OPTIONS.merge(force: true)

      def deploy
        load_ssh
        clone_repo
        load_events
        push_to_github
      end

      def load_ssh
        puts "Obtaining SSH key and known hosts…"

        s3 = Aws::S3::Client.new

        File.open(SSH_KEY_PATH, "w") do |file|
          s3.get_object(SSH_KEY_SOURCE, target: file)
        end

        File.open(KNOWN_HOSTS_PATH, "w") do |file|
          s3.get_object(KNOWN_HOSTS_SOURCE, target: file)
        end
      end

      def clone_repo
        puts "Cloning #{REPO_URL} into #{REPO_PATH}…"

        rm_rf REPO_PATH
        RubyGit.clone REPO_URL, REPO_PATH, GIT_TRANSPORT_OPTIONS
      end

      def load_events
        puts "Loading events…"

        Dir.chdir(REPO_PATH) do
          EventLoader.new(FACEBOOK_ACCESS_TOKEN, PAGE_ID).load
        end
      end

      def push_to_github
        puts "Committing and pushing to GitHub…"

        tree_hashmap = Dir.chdir REPO_PATH do
          files = Dir["{_data,images}/events/**/*"]

          files.each_with_object({}) do |path, hash|
            *dirs, file = path.split(File::SEPARATOR)
            parent = dirs.reduce(hash) { |tree, dir| tree[dir] ||= {} }
            parent[file] = File.read(path)
          end
        end

        root = Tree.new_from_hashmap(REPO, tree_hashmap, HEAD.tree)
        commit = Commit.new_with_tree(REPO, root, COMMIT_MESSAGE, COMMITTER, [HEAD])
        refspec = "#{commit.id}:#{TARGET_REF}"

        results = REPO.git.push(REMOTE_NAME, [refspec], PUSH_OPTIONS)
        updates = results.flat_map { |result| result.remote_updates.to_a }
        puts updates

        raise if updates.any? { |update| update.status.to_s != "OK" }
      end
    end
  end
end
