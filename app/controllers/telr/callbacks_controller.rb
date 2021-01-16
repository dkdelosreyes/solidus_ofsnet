# frozen_string_literal: true

module Telr
  class CallbacksController < Spree::StoreController

    class ErrorTelrCheckoutPaymentNotFound < StandardError; end

    skip_before_action :verify_authenticity_token

    # Deprecated since we are using Telr hosted V2
    def transaction
      callback_hash = Spree::PaymentMethod::TelrGateway.callback_hash(params)

      if callback_hash != params[:auth_hash]
        head :unauthorized and return
      end

      payment = Spree::Payment.find_by_number! params[:xtra_payment_number]

      head :ok

    rescue ActiveRecord::RecordNotFound => ex
      puts "OFSLOGS Telr::CallbacksController: #{ex}"
      head :not_found and return
    end

    def advice_service

      order = Spree::Order.find_by_number! params[:tran_cartid]

      checkout_state_payments = order.payments.telr_gateway.checkout

      raise ErrorTelrCheckoutPaymentNotFound.new if !checkout_state_payments.exists?

      payment = checkout_state_payments.last

      if ['A', 'H'].include?(params[:tran_status])

        case params[:tran_type]
        when 'void'
          payment.void!
        when 'refund'
          payment.credit!(params[:tran_amount])
        when 'sale'
          payment.capture!
        # when 'revrefund'
        # when 'auth'
        # when 'release'
        # when 'capture'
        # when 'revcapture'
        else
          puts "OFSLOGS Telr::CallbacksController advice_service: #{params}"
        end
      end

      payment.append_payload!(advice_service_params)

      head :ok

    rescue ActiveRecord::RecordNotFound => ex
      puts "OFSLOGS Telr::CallbacksController advice_service: #{ex} - #{params}"
      head :not_found and return
    rescue Telr::CallbacksController::ErrorTelrCheckoutPaymentNotFound => ex
      puts "OFSLOGS Telr::CallbacksController advice_service: #{ex} - #{params}"
      head :not_found and return
    end

    private

    def callback_params
      params.except(:auth_cvv, :auth_avs, :card_code, :card_desc)
    end

    def advice_service_params
      params.except(:card_code, :card_last4, :card_check, :cart_lang)
    end
  end
end
