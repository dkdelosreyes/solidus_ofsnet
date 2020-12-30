class ApplicationController < ActionController::Base
  before_action :load_country
  before_action :load_dir

  private

  def load_country
    @country = session[:country] || Spree::Country.default.iso
  end

  def load_dir
    @dir = (params[:locale] || session[:locale]) == 'ar' ? 'rtl' : 'ltr'
  end
end
