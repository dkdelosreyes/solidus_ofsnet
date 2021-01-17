module Spree::CountryDecorator

  # Get Any Country price if nothing was found
  def self.prepended(base)

    def base.available(restrict_to_zone: Spree::Config[:checkout_zone])
      checkout_zone = Spree::Zone.where(name: restrict_to_zone)

      country_ids = Spree::ZoneMember.where(zone_id: checkout_zone).where(zoneable_type: 'Spree::Country').pluck(:zoneable_id)

      return all if country_ids.empty?

      Spree::Country.where(id: country_ids)
    end
  end

  Spree::Country.prepend self
end