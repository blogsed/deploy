# frozen_string_literal: true
source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

group :run do
  gem "aws-sdk-core"
  gem "koala"
  gem "rjgit", github: "alyssais/rjgit"
end

group :build do
  gem "aws-sdk"
  gem "dotenv"
  gem "rake"
  gem "rubyzip", ">= 1.2.1"
end
