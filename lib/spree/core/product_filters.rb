# frozen_string_literal: true

module Spree
  module Core
    module ProductFilters

      Spree::Product.add_search_scope :ofs_price_range_any do |*opts|
        ranges = opts.first.split(';').map{|r| r.to_i}

        value = Spree::Price.arel_table
        Spree::Product.joins(master: :prices).where(value[:amount].between(ranges.first..ranges.last))
      end

      def self.format_price(amount)
        Spree::Money.new(amount)
      end

      def self.ofs_price_filter
        {
          name:   I18n.t('spree.price_range'),
          scope:  :ofs_price_range_any
        }
      end

      Spree::Product.add_search_scope :ofs_brand_any do |*opts|
        conds = opts.map { |value| ProductFilters.ofs_brand_filter[:conds][value] }.reject(&:nil?)
        scope = conds.shift
        conds.each do |new_scope|
          scope = scope.or(new_scope)
        end
        Spree::Product.with_property('brand').where(scope)
      end

      def self.ofs_brand_filter
        brand_property = Spree::Property.find_by(name: 'brand')
        brands = brand_property ? Spree::ProductProperty.where(property_id: brand_property.id).pluck(:value).uniq.map(&:to_s) : []
        pp = Spree::ProductProperty.arel_table
        conds = Hash[*brands.flat_map { |brand| [brand, pp[:value].eq(brand)] }]
        {
          name:   I18n.t('filters.brand'),
          scope:  :ofs_brand_any,
          conds:  conds,
          labels: brands.sort.map { |key| [key, key] }
        }
      end

      Spree::Product.add_search_scope :selective_brand_any do |*opts|
        Spree::Product.brand_any(*opts)
      end

      def self.selective_brand_filter(taxon = nil)
        taxon ||= Spree::Taxonomy.first.root
        brand_property = Spree::Property.find_by(name: 'brand')
        scope = Spree::ProductProperty.where(property: brand_property).
          joins(product: :taxons).
          where("#{Spree::Taxon.table_name}.id" => [taxon] + taxon.descendants)
        brands = scope.pluck(:value).uniq
        {
          name:   'Applicable Brands',
          scope:  :selective_brand_any,
          labels: brands.sort.map { |key| [key, key] }
        }
      end

      def self.taxons_below(taxon)
        Spree::Deprecation.warn "taxons_below is deprecated in solidus_core. Please add it to your own application to continue using it."
        return Spree::Core::ProductFilters.all_taxons if taxon.nil?
        {
          name:   'Taxons under ' + taxon.name,
          scope:  :taxons_id_in_tree_any,
          labels: taxon.children.sort_by(&:position).map { |element| [element.name, element.id] },
          conds:  nil
        }
      end

      def self.all_taxons
        Spree::Deprecation.warn "all_taxons is deprecated in solidus_core. Please add it to your own application to continue using it."
        taxons = Spree::Taxonomy.all.flat_map { |element| [element.root] + element.root.descendants }
        {
          name:   'All taxons',
          scope:  :taxons_id_equals_any,
          labels: taxons.sort_by(&:name).map { |element| [element.name, element.id] },
          conds:  nil # not needed
        }
      end
    end
  end
end
