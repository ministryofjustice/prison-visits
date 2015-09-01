class Feedback
  include NonPersistedModel

  attribute :text, String
  attribute :email, String
  attribute :referrer, String
  attribute :user_agent, String
  attribute :prison, String

  validates_presence_of :text
  validate :validate_email, if: ->(f) { f.email.present? }

  private

  def validate_email
    validator = EmailValidator.new(email)
    errors.add :email, validator.message unless validator.valid?
  end
end
