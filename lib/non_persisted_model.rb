module NonPersistedModel
  def self.included(receiver)
    receiver.send :include,
      Virtus.model,
      ActiveModel::Validations
  end

  def to_key
    [self.object_id]
  end

  def persisted?
    false
  end
end
