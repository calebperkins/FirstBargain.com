class Contact
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::MassAssignmentSecurity
  extend ActiveModel::Naming

  attr_accessor :email, :subject, :message
  attr_accessible :email, :subject, :message

  validates :email, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, presence: true
  validates :subject, :message, presence: true

  def initialize(attributes = {})
    sanitize_for_mass_assignment(attributes).each { |name, value| public_send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if valid?
      Stalker.enqueue("emails.contact_form", as_json)
      true
    else false
    end
  end

end
