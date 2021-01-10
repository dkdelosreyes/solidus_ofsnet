class AddPayloadToSpreePayments < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_payments, :payload, :jsonb, default: {}
  end
end
