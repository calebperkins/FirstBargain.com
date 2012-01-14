class ProductSweeper < ActionController::Caching::Sweeper
  observe Product
  
  def after_save(p)
    #expire_action p
    #expire_fragment(%r{member-shop/*}) # not working with Redis-Store, see https://github.com/jodosha/redis-store/pull/52
    if p.visible? || p.visible_changed? # invisible products need not be expired. However, on creation this will still expire.
      Rails.cache.delete_matched "views/member-shop/*"
    end
  end
end