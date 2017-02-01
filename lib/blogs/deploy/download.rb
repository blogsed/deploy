require "uri"
require "net/http"
require "pathname"

module BLOGS
  module Deploy
    module Download
      module_function

      def download(source, target = nil)
        source = URI(source)
        target = Pathname(target || File.basename(source.path))

        target.dirname.mkpath

        Net::HTTP.start(source.hostname) do |http|
          target.open "wb" do |file|
            http.request_get(source) do |response|
              response.read_body do |part|
                file.write(part)
              end
            end
          end
        end
      end
    end
  end
end
