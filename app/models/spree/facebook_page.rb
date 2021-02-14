module Spree
  class FacebookPage < Spree::Base
    has_many :facebook_page_live, dependent: :destroy
    belongs_to :user

    validates :facebook_page_id, presence: true, uniqueness: true
    validates :user_access_token, presence: true
    validates :page_access_token, presence: true

    def subscribe(access_token)
      self.user_access_token = FacebookPage.get_long_lived_token(access_token)
      self.page_access_token = FacebookPage.get_page_token(facebook_page_id, user_access_token) if self.user_access_token

      payload         = debug_token(access_token) if self.user_access_token
      self.expired_at = Time.at(payload['data_access_expires_at']).to_datetime
      self.payload    = payload

      params = {
        subscribed_fields: 'live_videos',
        access_token: self.page_access_token
      }

      response = Faraday.post("https://graph.facebook.com/#{facebook_page_id}/subscribed_apps", params)

      JSON.parse(response.body)

    rescue JSON::ParserError => ex
      puts "OFSLOGS Spree::FacebookPage#subscribe_live_videos: facebook_page_id: #{facebook_page_id}, page_access_token: #{page_access_token}, response: #{response}, ex: #{ex}"
      return false
    end

    def unsubscribe
      params = {
        access_token: self.page_access_token
      }

      response = Faraday.delete("https://graph.facebook.com/#{facebook_page_id}/subscribed_apps", params)

      JSON.parse(response.body)

    rescue JSON::ParserError => ex
      puts "OFSLOGS Spree::FacebookPage#unsubscribe_app: facebook_page_id: #{facebook_page_id}, response: #{response}, ex: #{ex}"
      return false
    end

    def debug_token(short_lived_token)
      params = {
        input_token: self.user_access_token,
        access_token: short_lived_token
      }

      response = Faraday.get("https://graph.facebook.com/debug_token", params)

      parsed_response = JSON.parse(response.body)

      parsed_response['data']

    rescue JSON::ParserError => ex
      puts "OFSLOGS Spree::FacebookPage#subscribe_live_videos: facebook_page_id: #{facebook_page_id}, page_access_token: #{page_access_token}, response: #{response}, ex: #{ex}"
      return false
    end

    class << self

      def get_long_lived_token(short_lived_token)
        credentials = ENV.fetch('FACEBOOK_APP_CREDENTIALS', '').split(':')
        params = {
          grant_type: 'fb_exchange_token',
          client_id: credentials[0],
          client_secret: credentials[1],
          fb_exchange_token: short_lived_token
        }

        response = Faraday.get('https://graph.facebook.com/v9.0/oauth/access_token', params)

        parsed_response = JSON.parse(response.body)

        parsed_response['access_token']

      rescue JSON::ParserError => ex
        puts "OFSLOGS Spree::FacebookPage#get_long_lived_token: short_lived_token: #{short_lived_token}, response: #{response}, ex: #{ex}"
        return false
      end

      def get_page_token(facebook_page_id, user_access_token)
        params = {
          fields: 'access_token',
          access_token: user_access_token
        }

        response = Faraday.get("https://graph.facebook.com/#{facebook_page_id}", params)

        parsed_response = JSON.parse(response.body)

        parsed_response['access_token']

      rescue JSON::ParserError => ex
        puts "OFSLOGS Spree::FacebookPage#get_page_token: facebook_page_id: #{facebook_page_id}, user_access_token: #{user_access_token}, response: #{response}, ex: #{ex}"
        return false
      end

    end
  end
end