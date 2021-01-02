class Spree::Admin::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth

    gmail_email = request.env['omniauth.auth'].info.email

    spree_user = Spree::User.find_by email: gmail_email.downcase

    if spree_user.blank? || spree_user.spree_roles.empty? || !sign_in(spree_user) || !spree_user_signed_in?
      flash[:alert] = t('devise.failure.unauthorized', email: gmail_email)
      redirect_to admin_login_path and return
    end

    respond_to do |format|
      format.html do
        flash[:success] = I18n.t('spree.logged_in_succesfully')
        redirect_to after_sign_in_path_for(spree_current_user)
      end
    end
  end

  def oauth_failure
    redirect_to admin_login_path
  end
end
