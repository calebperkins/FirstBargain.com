desc 'Expire all buy now prices older than 24 hours'
task :expire_investments => :environment do
  Investment.nonexpired.where("updated_at <= ?", Rails.configuration.buy_now_expiration.ago).update_all(expired: true)
end

desc "Clear the Rails cache"
task :clear_cache => :environment do
  Rails.cache.clear
end
