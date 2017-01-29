task :compile do
  require "opal"
  Opal.append_path("#{__dir__}/app")
  Opal.append_path("#{__dir__}/lib")
  file = "config/lambda.rb"
  code = %{require "base";} + File.read(file)
  builder = Opal::Builder.new
  File.write("config/lambda.js", builder.build_str(code, file))
end

alias _system system

def system(*args)
  puts "==> #{args.join(" ")}"
  _system(*args)
end

namespace :vendor do
  task :docker do
    system "docker", "build", "-f", "vendor/Dockerfile", "-t", "blogs-deploy", "."
  end

  def vendor(name)
    "#{__dir__}/vendor/#{name}"
  end

  task :git => :docker do
    system *%W{
      docker run --rm -v #{vendor "git"}:/host blogs-deploy sh -c #{<<-SH}}
      brew portable-package git && \
      cp -f *.bottle.tar.gz /host/git.x86_64.tar.gz
    SH
  end

  task :curl => :docker do
    system *%W{
      docker run --rm -v #{vendor "curl"}:/host blogs-deploy sh -c #{<<-SH}}
      brew portable-package curl && \
      cp -f *.bottle.tar.gz /host/curl.x86_64.tar.gz
    SH
  end

  task :jq => :docker do
    system *%W{
      docker run --rm -v #{vendor "jq"}:/host blogs-deploy sh -c #{<<-SH}}
      brew install --build-bottle --without-oniguruma portable-jq
      brew portable-package jq && \
      cp -f ".linuxbrew/opt/portable-jq/bin/jq" /host/
    SH
  end
end

task :dist do #=> [:compile, "vendor:git"] do
  require "zip"
  name = "dist.zip"
  File.delete(name)
  Zip::File.open(name, Zip::File::CREATE) do |zip|
    %w[app/deploy.sh config/lambda.js vendor/git/git.x86_64.tar.gz vendor/jq/jq].each do |file|
      zip.add(file, file)
    end
  end
end

task :default => :compile
