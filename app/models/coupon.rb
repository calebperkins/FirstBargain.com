# Leave uses left nil to be unlimited.
class Coupon < ActiveRecord::Base
  
  validates :code, :summary, :ends_at, :presence => true
  validates :bonuses, numericality: {:greater_than => 0}
  validates :uses_left, numericality: {greater_than_or_equal_to: 0, :allow_blank => true}

  def expired?
    ends_at.past? || uses_left.try(:<=, 0)
  end

end
