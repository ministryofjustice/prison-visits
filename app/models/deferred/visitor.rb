class Deferred::Visitor < Visitor
  validates :phone, absence: true, if: :additional?
  validates :phone, presence: true, length: { minimum: 9 }, if: :primary?
end
