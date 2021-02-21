module Spree::Admin
  class FacebookPageLiveController < ResourceController

    before_action :set_facebook_page_live, only: %w(destroy)

    def destroy
      if @facebook_page_live.destroy

        head :ok and return
      else
        render json: { message: "Deletion failed: #{facebook_page_live.errors}" }, status: :unprocessable_entity, layout: false and return
      end
    end

    private

    def set_facebook_page_live
      @facebook_page_live = Spree::FacebookPageLive.find params[:id]
    end
  end
end
