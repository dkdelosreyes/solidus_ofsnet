module Spree::Admin
  class FacebookPagesController < ResourceController

    before_action :set_facebook_page, only: %w(destroy edit update show sync_videos debug_token)

    def index
      @facebook_pages = Spree::FacebookPage.all
      @appid = ENV.fetch('FACEBOOK_APP_CREDENTIALS', '').split(':')[0]
    end

    def create

      respond_to do |format|

        format.json do

          fp = Spree::FacebookPage.find_or_initialize_by(facebook_page_id: params['id']) do |page|
            page.name       = params['name']
            page.user       = spree_current_user
          end

          if fp.new_record?
            subscribed = false

            subscribed = fp.subscribe(params['access_token'])

            if subscribed['success'] && fp.save
              render json: { message: 'Subscribed successfully' }, status: :ok, layout: false and return
            else
              render json: { message: "Subscription failed: #{subscribed['error']}" }, status: :unprocessable_entity, layout: false and return
            end

          else
            payload       = fp.debug_token(params['access_token'])
            fp.expired_at = Time.at(payload['data_access_expires_at']).to_datetime
            fp.payload    = payload

            render json: { message: 'This page is already subscribed.' }, status: :unprocessable_entity,  layout: false and return
          end
        end
      end
    end

    def edit
    end

    def update
      if @facebook_page.update(params_facebook_page)
        flash[:success] = 'Updated successfully'
        redirect_to action: :edit, id: @facebook_page.id
      else
        flash[:error] = "Update failed: errors: #{@facebook_page.errors.full_messages.join(', ')}"
        render :edit
      end
    end

    def show
      @lives = @facebook_page.facebook_page_live.order('creation_time desc')
    end

    def destroy
      unsubscribed = @facebook_page.unsubscribe

      if unsubscribed['success']

        @facebook_page.destroy

        head :ok and return
      else
        render json: { message: "Unsubscribe failed: #{unsubscribed['error']}" }, status: :unprocessable_entity, layout: false and return
      end
    end

    def debug_token
      # TODO
    end

    def sync_videos
      active, removed = @facebook_page.sync_live_videos

      flash[:success] = I18n.t('spree.admin.facebook_pages.sync_success', live_count: active, remove_count: removed)
      redirect_to action: :show, id: @facebook_page.id

    rescue => ex
      Rails.application.log :error, controller: self, action: 'sync_videos', facebook_page_id: @facebook_page.id, exception: ex
      flash[:error] = 'Latest videos failed to sync'
      redirect_to action: :show, id: @facebook_page.id
    end

    private

    def set_facebook_page
      @facebook_page = Spree::FacebookPage.find params[:id] || params[:facebook_page_id]
    end

    def params_facebook_page
      params.require(:facebook_page).permit(:user_access_token, :page_access_token)
    end
  end
end
