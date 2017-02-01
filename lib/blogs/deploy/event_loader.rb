require "yaml"
require "koala"

require_relative "download"

module BLOGS
  module Deploy
    class EventLoader
      include Download

      def initialize(facebook_access_token, id)
        @facebook = Koala::Facebook::API.new(facebook_access_token)
        @id = id
      end

      def load
        events = get_events

        write_events events
        events.each { |event| download_event_photo event }
      end

      private

      def get_events
        @facebook.get_connections(@id, :events,
          since: Time.now,
          fields: %i[
            id
            name
            description
            start_time
            end_time
            updated_time
          ],
        )
      end

      def write_events(events)
        yaml = YAML.dump("data" => events.to_a)

        FileUtils.mkdir_p("_data/events")
        File.write("_data/events/page.yml", yaml)
      end

      def download_event_photo(event)
        url = event_photo_url(event)
        download url, "images/events/#{event.fetch("id")}.jpeg"
      end

      def event_photo_url(event)
        event_id = event.fetch("id")

        photo = @facebook.get_connections(event_id, "photos").first
        return if photo.nil?
        photo_id = photo.fetch("id")

        @facebook.get_picture_data(photo_id)["data"].fetch("url")
      end
    end
  end
end
