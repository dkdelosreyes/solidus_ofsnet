# frozen_string_literal: true

module Telr
  class RequestsController < Spree::StoreController

    before_action :set_order, only: %{pay}

    def pay
      current_url  = ENV['NGROK_HOST'] || current_store.url
      redirect_url = spree.order_url(@order, host: current_url)

      redirect_to redirect_url, flash: { error: I18n.t('notices.already_paid', number: @order.number) } and return if @order.paid?

      redirect_to redirect_url, flash: { error: I18n.t('notices.already_completed', number: @order.number) } and return if @order.payments.telr_gateway.checkout.empty?

      current_url  = ENV['NGROK_HOST'] || current_store.url
      redirect_url = spree.order_url(@order, host: current_url)
      telr_url     = Rails.application.routes.url_helpers.telr_transaction_url(host: current_url)

      redirect_post(
        ENV['TELR_GATEWAY_URL'],
        params: Spree::PaymentMethod::TelrGateway.request_params(@order, current_store, telr_url, redirect_url),
        options: {
          method: :post,
          authenticity_token: 'auto'
        }
      )

    rescue Spree::PaymentMethod::TelrGateway::UnsupportedCurrency => ex
      puts "OFSLOGS Telr::RequestsController: #{ex}"
      redirect_to redirect_url, flash: { error: I18n.t('notices.unsupported_currency') }
    end

    private

    def set_order
      @order = Spree::Order.find_by_number! params[:id]
    end
  end
end
