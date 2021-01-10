# frozen_string_literal: true

require_dependency 'spree/calculator'
require_dependency 'spree/shipping_calculator'

module Spree
  module Calculator::Shipping
    class ByWeight < ShippingCalculator
      preference :amount, :decimal, default: 0
      preference :currency, :string, default: ->{ Spree::Config[:currency] }

      def compute_package(package)
        weight = package.weight > 0 ? package.weight : 1
        compute_from_weight(weight)
      end

      def compute_from_weight(weight)
        preferred_amount * weight
      end
    end
  end
end
