module Spree::PageDecorator

  def self.prepended(base)
    base.has_rich_text :body
    # base.has_many_attached :images
  end

  Spree::Page.prepend self
end