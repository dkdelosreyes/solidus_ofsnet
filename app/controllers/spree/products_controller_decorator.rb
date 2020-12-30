# frozen_string_literal: true

module Spree
  module ProductsControllerDecorator

    def self.prepended(base)
      base.include Spree::Core::ControllerHelpers::Pricing

      base.before_action :load_product, only: :show
      base.before_action :load_taxon, only: :index

      base.helper 'spree/taxons', 'spree/taxon_filters'

      base.respond_to :html
    end

    def index
      @searcher = build_searcher(params.merge(include_images: true))
      @products = @searcher.retrieve_products
      @max_price = Spree::Price.max_amount(current_pricing_options.currency)
      @taxonomies = Spree::Taxonomy.includes(root: :children)
    end

    def show
      # @variants = @product.
      #   variants.
      #   display_includes.
      #   with_prices(pricing_option).
      #   includes([:option_values])

      @variants = @product.
        variants_including_master.
        display_includes.
        with_prices(current_pricing_options).
        includes([:option_values, :images])

      @product_properties = @product.product_properties.includes(:property)
      @taxonomies = Spree::Taxonomy.includes(root: :children)
      @taxon = Spree::Taxon.find(params[:taxon_id]) if params[:taxon_id]
    end

    private

    def accurate_title
      if @product
        @product.meta_title.blank? ? @product.name : @product.meta_title
      else
        super
      end
    end

    def load_product
      if try_spree_current_user.try(:has_spree_role?, "admin")
        @products = Spree::Product.with_discarded
      else
        @products = Spree::Product.available
      end
      @product = @products.friendly.find(params[:id])
    end

    def load_taxon
      @taxon = Spree::Taxon.find(params[:taxon]) if params[:taxon].present?
    end

    Spree::ProductsController.prepend self
  end
end
