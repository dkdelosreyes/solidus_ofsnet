module Spree::PermissionSets::OrderManagementDecorator

  def activate!
    can :read, Spree::ReimbursementType
    can :manage, Spree::Order
    can :manage, Spree::Payment
    can :manage, Spree::Shipment
    can :manage, Spree::Adjustment
    can :manage, Spree::LineItem
    can :manage, Spree::ReturnAuthorization
    can :manage, Spree::CustomerReturn
    can :manage, Spree::OrderCancellations
    can :manage, Spree::Reimbursement
    can :manage, Spree::ReturnItem
    can :manage, Spree::Refund
    can :manage, Spree::SalePrice
  end

  Spree::PermissionSets::OrderManagement.prepend self
end