class AddExternalReferenceToSpreePayments < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_payments, :external_reference, :string
  end
end
