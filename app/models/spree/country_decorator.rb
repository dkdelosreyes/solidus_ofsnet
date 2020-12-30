module Spree::CountryDecorator

  # Get Any Country price if nothing was found
  def self.prepended(base)

    def base.available(restrict_to_zone: Spree::Config[:checkout_zone])
      checkout_zone = Spree::Zone.where(name: restrict_to_zone)

      list = []
      checkout_zone.find_each do |czone|
        list += czone.country_list if czone.try(:kind) == 'country'
      end

      list.any? ? list : all
    end
  end

  Spree::Country.prepend self
end