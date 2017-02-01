require "java"
require "json"
require "bundler/setup"

$:.unshift "uri:classloader:/lib"
require "blogs/deploy"

java_import "java.util.Map"

java_package "uk.org.blogs.deploy"

class LambdaHandler
  java_signature "Object call(Map event)"
  def call(event)
    puts "Received #{event.to_string}"
    return unless actionable?(event)

    BLOGS::Deploy::Deployment.new.deploy
  end

  private def actionable?(event)
    return true if event["detail-type"] == "Scheduled Event"

    puts "Not a scheduled event"

    event["Records"]&.any? do |record|
      data = JSON.parse(record.dig("Sns", "Message") || "{}")
      branch = data["ref"].split("/").last
      default_branch = data.dig("repository", "default_branch")
      puts "Received push to #{branch} (default: #{default_branch})"
      branch && branch == default_branch
    end
  end
end
