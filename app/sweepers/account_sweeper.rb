class AccountSweeper < ActionController::Caching::Sweeper
  observe Account
  
  def after_save(a)
    Rails.cache.delete_matched("homepage/*/#{a.id}") if a.credits_changed? || a.bonuses_changed?
  end
end