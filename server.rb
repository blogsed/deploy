require "sinatra"
require "json"

def received_data(data)
  return unless ref = data["ref"]
  return unless ref == "refs/heads/#{data["repository"]["default_branch"]}"
  system "#{__dir__}/deploy.sh"
end

post "/" do
  received_data JSON.parse request.body.read
  ""
end
