# frozen_string_literal: true

module Services
  module Facebook
    class WebhooksController < Spree::StoreController

      skip_before_action :verify_authenticity_token

      def verify
        if params["hub.verify_token"] == ENV["FACEBOOK_VERIFY_TOKEN"]
          render plain: params["hub.challenge"], content_type: 'text/plain'
        else
          head :unauthorized
        end
      end

      # status: unpublished, live, live_stopped, processing, vod
      def interact
        # todo: validate payload. https://developers.facebook.com/docs/graph-api/webhooks/getting-started
        # request.env['HTTP_X_HUB_SIGNATURE']

        # Rails.application.log :info, controller: self, action: 'interact', params: params

        params.fetch('entry', []).each do |entry|

          entry.fetch('changes', []).each do |event|

            next if event['field'] != 'live_videos' || [ 'live', 'vod' ].exclude?(event['value']['status'])

            facebook_page = Spree::FacebookPage.find_by_facebook_page_id entry['id']

            live = Spree::FacebookPageLive.find_or_initialize_by(video_id: event['value']['id']) do |vid|
              vid.facebook_page = facebook_page
            end

            status = event['value']['status'].downcase
            live.state = Spree::FacebookPageLive.states.include?(status) ? status : 'unpublished'

            live.get_info if live.new_record?

            if live.save

              facebook_page.remove_stale_videos

              head :ok and return
            else
              Rails.application.log :error, controller: self, event: event, errors: live.errors.full_messages
              head :unprocessable_entity and return
            end

          end

        end

        head :ok

      rescue ActiveRecord::RecordNotFound => ex
        Rails.application.log :error, controller: self, params: params, exception: ex
        head :unprocessable_entity and return
      end
    end
  end
end
