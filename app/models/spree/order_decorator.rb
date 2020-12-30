module Spree::OrderDecorator

  def self.prepended(base)
    base.validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, if: :require_email
  end

  Spree::Order.prepend self
end