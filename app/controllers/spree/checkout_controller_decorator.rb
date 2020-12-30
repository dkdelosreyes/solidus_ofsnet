# frozen_string_literal: true

module Spree
  module CheckoutControllerDecorator

    # Updates the order and advances to the next state (when possible.)
    def update
      success = true
      if params[:state].to_sym == :address
        success = verify_recaptcha(action: "checkout_form_#{params[:state]}", minimum_score: 0.4)
        success = verify_recaptcha(secret_key: ENV['RECAPTCHA_SECRET_KEY_V2']) unless success

        @show_checkbox_recaptcha = true if !success
      end

      if success && update_order

        assign_temp_address

        unless transition_forward
          redirect_on_failure
          return
        end

        if @order.completed?
          finalize_order
        else
          send_to_next_state
        end

      else
        render :edit
      end
    end

    private

    def finalize_order
      @current_order = nil
      set_successful_flash_notice
      redirect_completion_route
    end

    def redirect_completion_route
      if @order.payments.telr_gateway.checkout.exists?
        redirect_post_to_telr(@order)
      else
        redirect_to spree.order_path(@order)
      end
    end

    def redirect_post_to_telr(order)
      current_url  = ENV['NGROK_HOST'] || current_store.url
      telr_url     = Rails.application.routes.url_helpers.telr_transaction_url(host: current_url)
      redirect_url = spree.order_url(@order, host: current_url)

      redirect_post(
        ENV['TELR_GATEWAY_URL'],
        params: Spree::PaymentMethod::TelrGateway.request_params(order, current_store, telr_url, redirect_url),
        options: {
          method: :post,
          authenticity_token: 'auto'
        }
      )

    rescue Spree::PaymentMethod::TelrGateway::UnsupportedCurrency => ex
      puts "OFSLOGS Telr::RequestsController: #{ex}"
      redirect_to redirect_url, notice: 'Unsupported currency'
    end

    def before_address
      @order.assign_default_user_addresses
      # If the user has a default address, the previous method call takes care
      # of setting that; but if he doesn't, we need to build an empty one here
      @order.bill_address ||= Spree::Address.build_default
      @order.ship_address ||= Spree::Address.build_default if @order.checkout_steps.include?('delivery')

      @store_country = Spree::Country.where(iso: Spree::Order.last.store.cart_tax_country_iso)
    end

    Spree::CheckoutController.prepend self
  end
end
