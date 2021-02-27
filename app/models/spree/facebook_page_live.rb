module Spree
  class FacebookPageLive < Spree::Base
    belongs_to :facebook_page

    enum state: { unpublished: 0, live: 1, vod: 2 }

    validates :video_id, presence: true, uniqueness: true

    store_accessor :payload, :title, :embed_html, :description, :permalink_url

    scope :today, -> { where(creation_time: Date.today.all_day) }

    def get_info
      params = {
        fields: 'video,title,status,description,creation_time,permalink_url',
        access_token: facebook_page.user_access_token
      }

      response = Faraday.get("https://graph.facebook.com/v9.0/#{self.video_id}", params)

      parsed_response = JSON.parse(response.body)

      self.creation_time   = parsed_response['creation_time']
      self.payload         = parsed_response

    rescue JSON::ParserError => ex
      Rails.application.log :error, controller: self, action: 'subscribe_live_videos', facebook_page_id: facebook_page_id, response: response.body, exception: ex
      return false
    end

    def video_url
      ERB::Util.u "https://www.facebook.com/#{facebook_page.facebook_page_id}/videos/#{public_video_id}/"
    end

    def video_plugin_url
      "https://www.facebook.com/plugins/video.php?href=#{video_url}"
    end

    def public_video_id
      payload.dig('video', 'id')
    end

    def watch_url
      "https://www.facebook.com#{permalink_url}"
    end
  end
end