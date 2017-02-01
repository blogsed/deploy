begin
  require "dotenv/load"
rescue LoadError
  # dotenv is optional,
  # and not required in production.
end

module BLOGS
  module Deploy
    # Constants used by multiple modules.
    S3_BUCKET = "blogs.org.uk-deploy"
  end
end
