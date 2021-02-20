class LivesController < Spree::StoreController
  layout 'spree/layouts/spree_application'

  before_action :set_taxonomies, only: %w(index)

  def index

    return if !stale? last_modified: Spree::FacebookPageLive.maximum(:updated_at)

    # temp
    @lives = Spree::FacebookPageLive.live.order('creation_time desc').limit(1)
    @vod   = Spree::FacebookPageLive.vod.order('creation_time desc').limit(1)

    if @lives.empty? && @vod.any?
      arr_vod = @vod.to_a
      @lives = [ arr_vod.shift() ]
      @vod = arr_vod
    end
  end

  private

  def set_taxonomies
    @taxonomies = Spree::Taxonomy.includes(root: :children)
    @root_taxons = Spree::Taxon.roots
  end
end
