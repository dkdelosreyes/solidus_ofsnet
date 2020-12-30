# frozen_string_literal: true

module Telr
  class CallbacksController < Spree::StoreController
    skip_before_action :verify_authenticity_token

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
      callback_hash = Spree::PaymentMethod::TelrGateway.advice_service_hash(advice_service_params)

      if callback_hash != params[:tran_check]
        head :unauthorized and return
      end

      payment = Spree::Payment.find_by_number! params[:xtra_payment_number]

      if ['A', 'H'].include?(params[:tran_status])

        case params['tran_type']
        when 'void'
          payment.void!
        when 'refund'
          payment.credit!(params['tran_amount'])
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

      # binding.pry
      head :ok

    rescue ActiveRecord::RecordNotFound => ex
      puts "OFSLOGS Telr::CallbacksController advice_service: #{ex}"
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
