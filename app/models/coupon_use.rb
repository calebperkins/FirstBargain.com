class CouponUse < ActiveRecord::Base
  belongs_to :account
  belongs_to :coupon
  attr_reader :code
  delegate :bonuses, to: :coupon
  validates :account_id, presence: true
  validates :coupon_id, presence: true, uniqueness: {scope: :account_id}
  validate :expiration, if: :coupon_id?
  after_create :give_bids
  
  def code=(c)
    self.coupon = Coupon.find_by_code c
  end
  
  private
  
  def give_bids
    account.award(:bonuses, bonuses).save!
    coupon.decrement(:uses_left).save! if coupon.uses_left?
  end
  
  def expiration
    errors.add(:coupon_id, "has expired") if coupon.expired?
  end
  
end
