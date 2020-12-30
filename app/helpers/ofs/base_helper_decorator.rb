module Ofs
  module BaseHelperDecorator
    include Spree::BaseHelper

    def link_to_cart(text = nil)
      text = text ? h(text) : t('spree.cart')
      css_class = nil

      if current_order.nil? || current_order.item_count.zero?
        text = "#{text}: (#{t('spree.empty')})"
        css_class = 'empty'
      else
        text = "#{text}: (#{current_order.item_count})  <span class='amount'>#{current_order.display_total.to_html}</span>"
        css_class = 'full'
      end

      link_to text.html_safe, spree.cart_path, class: "cart-info #{css_class}"
    end

    def taxons_tree(root_taxon, current_taxon, max_level = 1)
      return '' if max_level < 1 || root_taxon.children.empty?
      content_tag :ul, class: '' do
        taxons = root_taxon.children.map do |taxon|
          css_class = (current_taxon && current_taxon.self_and_ancestors.include?(taxon)) ? '' : ''
          content_tag :li, class: css_class do
           link_to(taxon.name, seo_url(taxon)) +
             taxons_tree(taxon, current_taxon, max_level - 1)
          end
        end
        safe_join(taxons, "\n")
      end
    end

    def badge_class(state)
      base_class = 'badge badge-pill'
      colorize = if ['balance_due', 'credit_owed', 'failed', 'invalid', 'void'].include?(state)
        'badge-danger'

      elsif ['paid', 'complete', 'shipped'].include?(state)
        'badge-success'

      elsif ['balance_due', 'pending', 'awaiting_return', 'backorder', 'canceled'].include?(state)
        'badge-warning'

      else
        'badge-secondary'
      end

      "#{base_class} #{colorize}"
    end

    def ofs_applicable_filters_for(_taxon)
      [:ofs_brand_filter, :ofs_price_filter].map do |filter_name|
        Spree::Core::ProductFilters.send(filter_name) if Spree::Core::ProductFilters.respond_to?(filter_name)
      end.compact
    end

    def ofs_datepicker_field_value(date, with_time: false)
      date_tmp = date || Time.now

      format = if with_time
        t('spree.date_picker.format_with_time', default: '%Y/%m/%d %H:%M')
      else
        t('spree.date_picker.format', default: '%Y/%m/%d')
      end

      l(date_tmp, format: format)
    end

  end
end
