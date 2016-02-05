#!/usr/bin/env ruby

require "dotenv"
Dotenv.load

require "codeship"
project = Codeship::Projects.new(ENV["API_KEY"]).project(ENV["PROJECT_ID"])
Codeship::Builds.new(ENV["API_KEY"]).restart(project["builds"].first["id"])
