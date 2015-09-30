require 'zlib'

class CompressedMarshaller
  def dump(obj)
    compress(serialize(obj))
  end

  def load(source)
    deserialize(decompress(source))
  end

  private

  def compress(str)
    Zlib::Deflate.deflate(str, Zlib::BEST_COMPRESSION)
  end

  def decompress(compressed)
    Zlib::Inflate.inflate(compressed)
  end

  def serialize(obj)
    JSON.generate(obj)
  end

  def deserialize(str)
    JSON.parse(str)
  rescue JSON::ParserError
    Rails.logger.info 'Deserializing legacy token'
    Marshal.load(str)
  end
end
