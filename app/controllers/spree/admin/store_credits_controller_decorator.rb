module Spree::Admin
  module StoreCreditsControllerDecorator

    def self.prepended(base)
      base.prepend_before_action :set_store_currencies, only: [:new, :edit]
    end

    private

    def set_store_currencies
      @available_currencies = []
      Spree::Store.pluck(:default_currency).each do |default_currency|
        id, _ = Money::Currency.table.find { |key, currency| currency[:iso_code] == default_currency }
        @available_currencies << Money::Currency.new(id)
      end
      @available_currencies
    end

    Spree::Admin::StoreCreditsController.prepend self
  end
end