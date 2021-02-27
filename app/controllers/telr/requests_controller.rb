# frozen_string_literal: true

module Telr
  class RequestsController < Spree::StoreController

    before_action :set_order, only: %{pay}

    def pay
      current_url  = ENV['NGROK_HOST'] || current_store.url
      telr_url     = Rails.application.routes.url_helpers.telr_transaction_url(host: current_url)
      redirect_url = spree.order_url(@order, host: current_url)

      redirect_to redirect_url, flash: { error: I18n.t('notices.already_paid', number: @order.number) } and return if @order.paid?
      redirect_to redirect_url, flash: { error: I18n.t('notices.already_completed', number: @order.number) } and return if @order.payments.telr_gateway.checkout.empty?

      params = Spree::PaymentMethod::TelrGateway.request_params(@order, current_store, telr_url, redirect_url)

      response = Faraday.post(ENV['TELR_GATEWAY_URL_V2'], params, { 'X-Accept' => 'application/json' })

      body = JSON.parse response.body

      if body['error'].present?
        Rails.application.log :error, controller: Telr::RequestsController, action: 'pay', body: body

        flash[:alert] = "#{body['error']['message']}. #{body['error']['note']}"
        redirect_to spree.order_path(@order) and return
      end

      payment = @order.payments.telr_gateway.checkout.last
      payment.external_reference!(body['order']['ref'])

      redirect_to body['order']['url']

    rescue Spree::PaymentMethod::TelrGateway::UnsupportedCurrency => ex
      Rails.application.log :error, controller: self, action: 'pay', order_id: order.id, exception: ex

      redirect_to redirect_url, flash: { error: I18n.t('notices.unsupported_currency') }
    rescue JSON::ParserError => ex
      Rails.application.log :error, controller: self, response: response.body, exception: ex
    end

    private

    def set_order
      @order = Spree::Order.find_by_number! params[:id]
    end
  end
end
