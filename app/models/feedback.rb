class Feedback
  include NonPersistedModel

  attribute :text, String
  attribute :email, String
  attribute :referrer, String
  attribute :user_agent, String
  attribute :prison, String

  validates_presence_of :text
  validates :email, email: true, if: ->(f) { f.email.present? }
end
