require 'zlib'

module ZMarshal
  def self.dump(obj)
    Zlib::Deflate.deflate(Marshal.dump(obj), Zlib::BEST_COMPRESSION)
  end

  def self.load(source)
    Marshal.load(Zlib::Inflate.inflate(source))
  end
end
