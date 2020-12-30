# frozen_string_literal: true

module Spree
  module TaxonsControllerDecorator

    def show
      @searcher = build_searcher(params.merge(taxon: @taxon.id, include_images: true))
      @products = @searcher.retrieve_products

      @max_price = Spree::Price.max_amount(current_pricing_options.currency)
      @taxonomies = Spree::Taxonomy.includes(root: :children)
      @root_taxons = Spree::Taxon.roots
    end

    Spree::TaxonsController.prepend self
  end
end
