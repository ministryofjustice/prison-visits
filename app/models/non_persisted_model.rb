module NonPersistedModel
  #
  # Note: this module is needed so that it can be included last and thus
  # override the definition of to_global_id supplied by
  # GlobalID::Identification.
  #
  module InstanceMethods
    def to_key
      [self.object_id]
    end

    def persisted?
      false
    end

    def to_global_id
      hash = RecursiveHasher.new.export(self)

      "gid://pvb/%s/%s" % [
        self.class.to_s,
        Base64.urlsafe_encode64(JSON.dump(hash))
      ]
    end
  end

  def self.included(receiver)
    receiver.send :include, Virtus.model
    receiver.send :include, ActiveModel::Validations
    receiver.send :include, GlobalID::Identification
    receiver.send :include, InstanceMethods
  end
end
