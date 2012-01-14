class Address < ActiveRecord::Base
  belongs_to :account, inverse_of: :addresses
  validates :account_id, :name, :label, :address, :city, :state, :presence => true
  validates :phone, :zip, numericality: true
  attr_accessible :name, :address, :address_2, :city, :state, :zip, :country, :phone, :label
  before_validation :fix_phone
  
  STATES = ['AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'IA', 'ID',
    'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME','MI','MN','MO','MS','MT','NC','ND','NE','NH',
    'NJ','NM','NV','NY','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VA','VT','WA','WI','WV', 'WY'].freeze

  private

  def fix_phone
    phone.gsub! /-/, ""
  end

end
