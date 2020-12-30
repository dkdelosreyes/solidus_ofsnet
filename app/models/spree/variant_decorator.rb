module Spree::VariantDecorator

  def options_text
    values = option_values.includes(:option_type).sort_by do |option_value|
      option_value.option_type.position
    end

    values.to_a.map! do |ov|
      "#{ov.presentation}"
    end

    values.to_sentence({ words_connector: ", ", two_words_connector: ", " })
  end

  Spree::Variant.prepend self
end