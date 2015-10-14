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
    checker = EmailChecker.new(email)
    errors.add :email, checker.message unless checker.valid?
  end
end
