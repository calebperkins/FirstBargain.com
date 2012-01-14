# A picture for a product.
class Picture < ActiveRecord::Base
  belongs_to :product, inverse_of: :pictures
  validates :data, :presence => true
  mount_uploader :data, ProductImageUploader
end
