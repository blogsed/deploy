require "bundler/setup"
$:.unshift File.expand_path("lib", __dir__)

require "blogs/deploy/env"
require "blogs/deploy/download"

JRUBY_URL = "https://s3.amazonaws.com/jruby.org/downloads/" \
  "#{JRUBY_VERSION}/jruby-complete-#{JRUBY_VERSION}.jar"

Rake::FileUtilsExt.verbose false

file "vendor/bundle" => "Gemfile.lock" do |task|
  puts "Vendoring dependencies…"

  reset_bundler do
    raise unless system *%W[ bundle install
      --standalone --deployment --clean --quiet
      --path #{task.name} --without development ]
  end

  # This needs to be done for two reasons:
  # - The top-level bundle directory isn't modified (only its children are),
  #   so it needs to be touched for Rake to notice the changes.
  # - Bundler updates the Gemfile.lock timestamp _after_ creating the bundle.
  #   This means that Rake will _always_ recreate the bundle, which isn't
  #   necessary. This touch ensures the bundle timestamp is later than
  #   Gemfile.lock's.
  touch task.name
end

file "vendor/jruby-#{JRUBY_VERSION}.jar" do |task|
  puts "Downloading JRuby #{JRUBY_VERSION}…"

  BLOGS::Deploy::Download.download(JRUBY_URL, task.name)
end

file "build/java" => "config/aws_lambda.rb" do |task|
  puts "Compiling Java classes…"

  mkdir_p task.name
  system "jrubyc", "--javac", "--target", task.name, *files(task)

  # This directory itself isn't modified (only its subdirectories are),
  # so it needs to be touched to get Rake to notice the changes.
  touch task.name
end

file "build/blogs-deploy.jar" => FileList[
  "vendor/bundle", "vendor/jruby-#{JRUBY_VERSION}.jar",
  "build/java", "lib/**/*",
] do
  require "zip"

  puts "Copying files to jar…"

  cp "vendor/jruby-#{JRUBY_VERSION}.jar", "build/blogs-deploy.jar"

  Zip::File.open("build/blogs-deploy.jar") do |jar|
    Dir["vendor/bundle/**/{*.*}"].each do |source|
      next if source =~ %r{^vendor/bundle/jruby/.*/cache}
      target = relative_path(source, from: "vendor/bundle")
      jar.add(target, source)
    end

    Dir["build/java/**/*.class"].each do |source|
      target = relative_path(source, from: "build/java")
      jar.add(target, source)
    end

    Dir["lib/**/*"].each do |file|
      jar.add(file, file)
    end
  end
end

task :deploy => "build/blogs-deploy.jar" do |task|
  require "aws-sdk"

  s3 = Aws::S3::Resource.new
  object = s3.bucket("blogs.org.uk-deploy").object("blogs-deploy.jar")
  files(task).each do |file|
    puts "Uploading #{file} to Amazon S3…"
    object.upload_file file
  end

  puts "Updating AWS Lambda function…"
  lambda = Aws::Lambda::Client.new
  lambda.update_function_code(
    function_name: "blogs-deploy",
    s3_bucket: "blogs.org.uk-deploy",
    s3_key: "blogs-deploy.jar",
  )
end

task :default => "build/blogs-deploy.jar"

def reset_bundler
  if Dir.exist?(".bundle")
    bundle_tmpdir = Dir.mktmpdir
    mv ".bundle", bundle_tmpdir
  end

  Bundler.with_clean_env { yield }
ensure
  rm_rf ".bundle"
  if bundle_tmpdir
    mv "#{bundle_tmpdir}/.bundle", "."
    remove_entry bundle_tmpdir
  end
end

def relative_path(absolute_path, from:)
  absolute_path = Pathname(absolute_path)
  base_path = Pathname(from)

  absolute_path.relative_path_from(base_path).to_path
end

def files(task)
  task.prerequisite_tasks.select { |t| t.is_a? Rake::FileTask }.map(&:name)
end
