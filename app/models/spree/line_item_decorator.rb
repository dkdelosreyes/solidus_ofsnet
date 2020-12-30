module Spree::LineItemDecorator

  def self.prepended(base)
    base.validates :quantity, numericality: {
      only_integer: true,
      greater_than: -1,
      less_than: 6
    }
  end

  Spree::LineItem.prepend self
end