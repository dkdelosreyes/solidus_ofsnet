module Spree::Admin
  module PricesControllerDecorator

    def self.prepended(base)
      base.prepend_before_action :set_store_country, only: [:new, :edit]
      base.prepend_before_action :set_store_currencies, only: [:new, :edit]
    end

    private

    def set_store_country
      spree_stores      = Spree::Store.all

      @default_currency = spree_stores.default.default_currency
      @country_currency = spree_stores.pluck(:cart_tax_country_iso, :default_currency).to_h
      @store_country    = Spree::Country.where(iso: spree_stores.where(default: false).pluck(:cart_tax_country_iso))
    end

    def set_store_currencies
      @setCurrencyByCountry = true
      @available_currencies = []
      Spree::Store.pluck(:default_currency).each do |default_currency|
        id, _ = Money::Currency.table.find { |key, currency| currency[:iso_code] == default_currency }
        @available_currencies << Money::Currency.new(id)
      end
      @available_currencies
    end

    Spree::Admin::PricesController.prepend self
  end
end