# frozen_string_literal: true

module Spree
  class PaymentMethod
    class TelrGateway < Spree::PaymentMethod

      class UnsupportedCurrency < StandardError; end

      preference :aed_to_php_exchange_rate, :decimal
      preference :supported_currency, :string

      TELR_STORE_SECRET="L$vx5nV2Jf"

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
        ivp_timestamp = 0 # Causing "Cart timestamp is out of range". Time.now.utc.to_i
        ivp_extra     = 'bill,return,xtra'

        ivp = []
        ivp << Spree::PaymentMethod::TelrGateway::TELR_STORE_SECRET
        ivp << ENV['TELR_STORE_ID']
        ivp << ivp_amount
        ivp << ivp_currency
        ivp << ivp_test
        ivp << ivp_timestamp
        ivp << ivp_cart
        ivp << ivp_desc
        ivp << ivp_extra
        ivp_signature = Digest::SHA1.hexdigest ivp.join(':')

        bill_title   = ''
        bill_fname   = order.bill_address.name
        bill_sname   = order.bill_address.name
        bill_addr1   = order.bill_address.address1
        bill_addr2   = order.bill_address.address2
        bill_addr3   = ''
        bill_city    = order.bill_address.city
        bill_region  = ''
        bill_country = order.bill_address.country.iso
        bill_zip     = order.bill_address.zipcode
        bill_email   = order.email

        bill = []
        bill << Spree::PaymentMethod::TelrGateway::TELR_STORE_SECRET
        bill << bill_title
        bill << bill_fname
        bill << bill_sname
        bill << bill_addr1
        bill << bill_addr2
        bill << bill_addr3
        bill << bill_city
        bill << bill_region
        bill << bill_country
        bill << bill_zip
        bill << ivp_signature
        bill_signature = Digest::SHA1.hexdigest bill.join(':')

        telr_transaction_url = telr_url
        store_redirect_url   = "auto:#{redirect_url}"
        return_auth    = store_redirect_url
        return_decl    = store_redirect_url
        return_can     = store_redirect_url
        return_cb_auth = telr_transaction_url
        return_cb_decl = telr_transaction_url
        return_cb_can  = telr_transaction_url

        ret = []
        ret << Spree::PaymentMethod::TelrGateway::TELR_STORE_SECRET
        ret << return_cb_auth
        ret << return_cb_decl
        ret << return_cb_can
        ret << return_auth
        ret << return_decl
        ret << return_can
        ret << ivp_signature
        return_signature = Digest::SHA1.hexdigest ret.join(':')

        xtra_payment_number = order.payments.telr_gateway.checkout.last.number
        xtra_fields         = 'xtra_payment_number'

        xtra = []
        xtra << Spree::PaymentMethod::TelrGateway::TELR_STORE_SECRET
        xtra << xtra_payment_number
        xtra << xtra_fields
        xtra << ivp_signature
        xtra_signature = Digest::SHA1.hexdigest xtra.join(':')

        return {
          ivp_store:     ENV['TELR_STORE_ID'],
          ivp_amount:    ivp_amount,
          ivp_currency:  ivp_currency,
          ivp_test:      ivp_test,
          ivp_cart:      ivp_cart,
          ivp_desc:      ivp_desc,
          ivp_signature: ivp_signature,
          ivp_timestamp: ivp_timestamp,
          ivp_extra:     ivp_extra,

          bill_title:     '',
          bill_fname:     bill_fname,
          bill_sname:     bill_sname,
          bill_addr1:     bill_addr1,
          bill_addr2:     bill_addr2,
          bill_addr3:     bill_addr3,
          bill_city:      bill_city,
          bill_region:    bill_region,
          bill_country:   bill_country,
          bill_zip:       bill_zip,
          bill_email:     bill_email,
          bill_signature: bill_signature,

          return_auth:      return_auth,
          return_decl:      return_decl,
          return_can:       return_can,
          return_cb_auth:   return_cb_auth,
          return_cb_decl:   return_cb_decl,
          return_cb_can:    return_cb_can,
          return_signature: return_signature,

          xtra_payment_number: xtra_payment_number,
          xtra_fields:     xtra_fields,
          xtra_signature:  xtra_signature
        }
      end

      def callback_hash(params)
        cb = []
        cb << Spree::PaymentMethod::TelrGateway::TELR_STORE_SECRET
        cb << params[:auth_status]
        cb << params[:auth_code]
        cb << params[:auth_message]
        cb << params[:auth_tranref]
        cb << params[:auth_cvv]
        cb << params[:auth_avs]
        cb << params[:card_code]
        cb << params[:card_desc]
        cb << params[:cart_id]
        cb << params[:cart_desc]
        cb << params[:cart_currency]
        cb << params[:cart_amount]
        cb << params[:tran_currency]
        cb << params[:tran_amount]
        cb << params[:tran_cust_ip]

        Digest::SHA1.hexdigest cb.join(':')
      end

      def advice_service_hash(params)
        cb = []
        cb << Spree::PaymentMethod::TelrGateway::TELR_STORE_SECRET
        cb << params[:tran_store]
        cb << params[:tran_type]
        cb << params[:tran_class]
        cb << params[:tran_test]
        cb << params[:tran_ref]
        cb << params[:tran_prevref]
        cb << params[:tran_firstref]
        cb << params[:tran_currency]
        cb << params[:tran_amount]
        cb << params[:tran_cartid]
        cb << params[:tran_desc]
        cb << params[:tran_status]
        cb << params[:tran_authcode]
        cb << params[:tran_authmessage]

        Digest::SHA1.hexdigest cb.join(':')
      end
    end
  end
end
