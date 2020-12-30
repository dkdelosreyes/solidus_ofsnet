# frozen_string_literal: true

module Spree::Variant::PriceSelectorDecorator

  def price_for(price_options, to_money = true)
    matched_price = variant.currently_valid_prices.detect do |price|
      ( price.country_iso == price_options.desired_attributes[:country_iso] ||
        price.country_iso.nil?
      ) && price.currency == price_options.desired_attributes[:currency]
    end

    to_money ? matched_price.try!(:money) : matched_price
  end

  Spree::Variant::PriceSelector.prepend self
end
