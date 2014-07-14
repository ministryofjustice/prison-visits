class String
  def secure_compare(other)
    return false unless self.class === other
    return false unless self.bytesize == other.bytesize

    l = self.unpack "C#{self.bytesize}"
    res = 0
    other.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end
end
