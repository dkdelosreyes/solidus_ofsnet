module Spree
  module UsersControllerDecorator

    def show

      skope = @user.orders.complete

      return if !stale? last_modified: skope.maximum(:updated_at)
      @orders = skope.order('completed_at desc').page(params[:page]).per(5)
    end

    Spree::UsersController.prepend self
  end
end