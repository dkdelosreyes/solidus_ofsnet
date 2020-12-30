module Spree::PriceDecorator

  def self.prepended(base)
    base.scope :for_specific_country, -> { where.not(country: nil) }

    def base.max_amount(currency)
      where(currency: currency).maximum(:amount)
    end
  end

  def on_sale?
    false
  end

  Spree::Price.prepend self
end