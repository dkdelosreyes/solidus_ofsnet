# frozen_string_literal: true

module Spree
  class PaymentMethod
    class TelrGateway < Spree::PaymentMethod

      class UnsupportedCurrency < StandardError; end

      preference :aed_to_php_exchange_rate, :decimal
      preference :supported_currency, :string

      AUTH_KEY='kwtqd~rtbT^KNCp3'

      def gateway_class
        self.class
      end

      def partial_name
        "telr_gateway"
      end

      def actions
        %w{}
      end

      # Indicates whether its possible to capture the payment
      def can_capture?(payment)
        ['checkout', 'pending'].include?(payment.state)
      end

      # Indicates whether its possible to void the payment.
      def can_void?(payment)
        payment.state != 'void'
      end

      def capture(*)
        simulated_successful_billing_response('Captured')
      end

      def void(*)
        simulated_successful_billing_response('Void')
      end
      alias_method :try_void, :void

      # Refund
      def credit(*)
        simulated_successful_billing_response('Credit')
      end

      def source_required?
        false
      end

      def simulated_successful_billing_response(msg)
        ActiveMerchant::Billing::Response.new(true, msg, {}, {})
      end
    end

    class << self

      def request_params(order, store, telr_url, redirect_url)
        gateway  = order.payments.telr_gateway.last.payment_method
        amount   = order.total.to_f
        currency = 'AED'

        supported_currencies = gateway.preferred_supported_currency.present? ? gateway.preferred_supported_currency.split(',') : 'AED'
        if !supported_currencies.include?(store.default_currency)
          if store.default_currency == 'PHP'
            amount   = order.total / gateway.preferred_aed_to_php_exchange_rate
            currency = supported_currencies.first
          else
            raise Spree::PaymentMethod::TelrGateway::UnsupportedCurrency.new
          end
        end

        ivp_amount    = amount.to_f
        ivp_currency  = currency
        ivp_test      = order.payments.telr_gateway.last.payment_method.preferred_test_mode ? 1 : 0
        ivp_cart      = order.number
        ivp_desc      = I18n.t('telr.ivp_desc', number: order.number, name: order.email)

        return {
          ivp_method:   'create',
          ivp_store:    ENV['TELR_STORE_ID'],
          ivp_authkey:  Spree::PaymentMethod::TelrGateway::AUTH_KEY,
          ivp_amount:   ivp_amount,
          ivp_currency: ivp_currency,
          ivp_test:     ivp_test,
          ivp_cart:     ivp_cart,
          ivp_desc:     ivp_desc,
          return_auth:  redirect_url,
          return_decl:  redirect_url,
          return_can:   redirect_url,
          bill_title:   '',
          bill_fname:   order.bill_address.first_name,
          bill_sname:   order.bill_address.last_name,
          bill_addr1:   order.bill_address.address1,
          bill_addr2:   order.bill_address.address2,
          bill_addr3:   '',
          bill_city:    order.bill_address.city,
          bill_region:  '',
          bill_country: order.bill_address.country.iso,
          bill_zip:     order.bill_address.zipcode,
          bill_email:   order.email
        }
      end
    end
  end
end
