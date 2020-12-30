module ApplicationHelper
  include Ofs::BaseHelperDecorator

  def available_country
    configured = Spree::Store.pluck(:cart_tax_country_iso)

    configured.any? ? configured : [Spree::Config.default_country_iso]
  end
end
