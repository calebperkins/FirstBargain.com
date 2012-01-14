class Approval < ActiveRecord::Base
  after_commit :clear_cache

  def self.without?(ip)
    ips = Rails.cache.fetch("approved-ips") do
      all.collect(&:ip)
    end
    not ips.include?(ip)
  end

  private

  def clear_cache
    Rails.cache.delete("approved-ips")
  end

end
