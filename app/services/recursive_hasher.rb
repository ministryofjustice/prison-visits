class RecursiveHasher
  def export(node)
    if node.respond_to?(:attributes)
      Hash[node.attributes.map { |name, value|
        [name, export(value)]
      }]
    elsif node.is_a?(Array)
      node.map { |a| export(a) }
    else
      node
    end
  end

  # This method is essentially useless, as it does nothing that klass.new(hash)
  # doesn't. However, it gives us an explicit symmetrical export and import,
  # and makes the boundaries where we are converting to and from hashes clear.
  # It's also tested, which means that we can be confident that klass.new
  # behaves as we want, especially with respect to attributes that are
  # themselves models.
  #
  def import(hash, klass)
    klass.new(hash)
  end
end
