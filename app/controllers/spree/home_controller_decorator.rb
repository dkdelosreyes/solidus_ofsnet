# frozen_string_literal: true

module Spree
  module HomeControllerDecorator

    def self.prepended(base)
      base.layout 'spree/layouts/basic'
      base.helper 'spree/products'
      base.respond_to :html
    end

    def index
      # puts "OFS LOGS Spree store URLs: #{Spree::Store.pluck(:url)}"
      # puts "OFS LOGS Server Name: #{request.env['SERVER_NAME']}"
      # puts "OFS LOGS current_pricing_options: #{current_pricing_options.currency}"
      @taxonomies = Spree::Taxonomy.includes(root: :children)
      @root_taxons = Spree::Taxon.roots
    end

    def country
      requested_country = params[:co]

      if requested_country && available_country.map(&:to_s).include?(requested_country)

        session[:country] = requested_country
        currency = requested_country == 'AE' ? 'AED' : 'PHP'

        current_order.update_attributes!(currency: currency) if current_order
      end

      redirect_to spree.root_path
    end

    Spree::HomeController.prepend self
  end
end
