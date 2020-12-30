module Spree::PaymentDecorator

  def self.prepended(base)
    base.scope :telr_gateway, -> { joins(:payment_method).where(spree_payment_methods: { type: 'Spree::PaymentMethod::TelrGateway' }) }
  end

  def telr_gateway?
    payment_method.is_a? Spree::PaymentMethod::TelrGateway
  end

  def credit!(amount)
    refund        = self.refunds.new
    refund.amount = amount.to_d
    refund.reason = Spree::RefundReason.first

    refund.save
  end

  def append_payload!(params)

    if self.payload.size == 0 || self.payload.nil?
      self.payload = [params]
    else
      self.payload << params
    end

    self.save
  end

  Spree::Payment.prepend self
end