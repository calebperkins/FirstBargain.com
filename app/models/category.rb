class Category < ActiveRecord::Base
  has_many :products, :dependent => :restrict
  validates :name, :presence => true
end
