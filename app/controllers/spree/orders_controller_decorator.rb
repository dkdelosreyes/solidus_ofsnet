module Spree
  module OrdersControllerDecorator

    def self.prepended(base)
      base.layout 'spree/layouts/basic'
    end

    Spree::OrdersController.prepend self
  end
end
