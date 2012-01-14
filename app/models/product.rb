# A product that may be sold directly or auctioned off.
class Product < ActiveRecord::Base
  money :retail_price
  money :shipping_price
  money :max_discount
  money :tax
  money :cost

  mount_uploader :main_picture, MainPictureUploader

  has_many :auctions, inverse_of: :product, :dependent => :restrict
  has_many :pictures, inverse_of: :product, :dependent => :destroy
  belongs_to :category, inverse_of: :products
  accepts_nested_attributes_for :pictures, :allow_destroy => true, :reject_if => proc { |attributes| attributes['data'].blank? }

  validates :name, :summary, :description, :category_id, :main_picture, :presence => true
  validates :visible, :requires_shipping, :inclusion => [true, false]
  validates :retail_price, numericality: {:greater_than => 0}
  validates :shipping_price, :cost, :max_discount, :bonuses, :tax, numericality: {greater_than_or_equal_to: 0}

  scope :store, where(visible: true, discontinued: false).order('products.id DESC')

  def point_discount(user)
    user ? [user.points, max_discount].min : 0.to_money
  end

  # MSRP - (# of member points up to x% of MSRP)
  def reward_price(user)
    retail_price - point_discount(user)
  end

  def display_price(user)
    retail_price - display_discount(user)
  end

  def display_discount(user)
    user ? [max_discount, user.points].min : max_discount
  end
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
  def bid_pack?
    category_id == 1
  end
  
  def cog
    retail_price - bonuses * Rails.configuration.bid_unit_price
  end

end
