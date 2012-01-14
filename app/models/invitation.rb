class Invitation
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :name, :sender
  attr_reader :emails
  
  attr_accessor_with_default :addresses, []

  attr_accessor_with_default :message do
    "Hey,\n\nI'd like to invite you to First Bargain, a members-only auction site where you can walk away with unheard of deals on today's hottest gadgets and designer products.\n\nMembership is free, so join me today on FirstBargain.com to start saving big on all the brands you love!\n\n#{sender.referral_link}"
  end
  
  attr_protected :sender, :addresses

  validate :check_emails
  validates :message, :name, :sender, presence: true

  def initialize(s, attributes = {})
    sanitize_for_mass_assignment(attributes).each {|name, value| public_send("#{name}=", value)}
    self.sender = s
  end

  def emails=(a)
    @emails = a
    self.addresses = a.split(',').each {|e| e.strip!}
  end

  def persisted?
    false
  end
  
  def save
    if valid?
      Stalker.enqueue("emails.customer", {method: :invitation, params: as_json})
      true
    else false
    end
  end
  
  def as_json(options = nil)
    {message: message, addresses: addresses, name: name}
  end

  private

  def check_emails
    errors.add(:emails, :length) unless (1..5) === addresses.size
    errors.add(:emails, :invalid) unless addresses.all? {|e| e =~ Authlogic::Regex.email}
  end

end
