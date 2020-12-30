# frozen_string_literal: true

module Spree::ProductDuplicatorDecorator

  protected

  def duplicate_product
    product.dup.tap do |new_product|
      new_product.name = "#{product.name} (Copy-#{Time.now.to_i})"
      new_product.taxons = product.taxons
      new_product.created_at = nil
      new_product.deleted_at = nil
      new_product.updated_at = nil
      new_product.product_properties = reset_properties
      new_product.master = duplicate_master
      new_product.variants = product.variants.map { |variant| duplicate_variant variant }
    end
  end

  def duplicate_master
    master = product.master
    master.dup.tap do |new_master|
      new_master.sku = "#{master.sku} (Copy-#{Time.now.to_i})"
      new_master.deleted_at = nil
      new_master.images = master.images.map { |image| duplicate_image image } if @include_images
      new_master.price = master.price
    end
  end

  def duplicate_variant(variant)
    new_variant = variant.dup
    new_variant.sku = "#{new_variant.sku} (Copy-#{Time.now.to_i})"
    new_variant.deleted_at = nil
    new_variant.option_values = variant.option_values.map { |option_value| option_value }
    new_variant
  end

  Spree::ProductDuplicator.prepend self
end
