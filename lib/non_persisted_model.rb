module NonPersistedModel

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
      hash = RecursiveHashGenerator.new.to_recursive_hash(self)

      "gid://pvb/%s/%s" % [
        self.class.to_s,
        Base64.urlsafe_encode64(JSON.dump(hash))
      ]
    end
  end

  class RecursiveHashGenerator
    def to_recursive_hash(obj)
      if obj.nil?
        nil
      elsif obj.respond_to?(:to_hash)
        process_hash(obj.to_hash)
      elsif obj.respond_to?(:to_h)
        process_hash(obj.to_h)
      elsif obj.respond_to?(:map)
        process_array(obj)
      else
        obj
      end
    end

    private

    def process_hash(h)
      # TODO: Change this to .to_h when Ruby is updated
      Hash[h.map{ |k, v| [k, to_recursive_hash(v)] }]
    end

    def process_array(ary)
      ary.map { |a| to_recursive_hash(a) }
    end
  end


  def self.included(receiver)
    receiver.send :include, Virtus.model
    receiver.send :include, ActiveModel::Validations
    receiver.send :include, GlobalID::Identification
    receiver.send :include, InstanceMethods
  end
end
