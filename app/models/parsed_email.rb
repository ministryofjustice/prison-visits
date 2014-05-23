class ParsedEmail
  include ActiveModel::Model

  ParseError = Class.new(StandardError)

  attr_accessor :from, :to, :subject, :text

  def self.parse(hash)
    hash = hash.dup
    raise ParseError.new("Missing subject") unless hash[:subject]
    raise ParseError.new("Missing email body") unless hash[:text]
    charsets = JSON.parse(hash[:charsets]).with_indifferent_access

    [:subject, :text].each do |field|
      # Fields can have different encodings, normalize everything to UTF-8

      if encoding = charsets[field]
        hash[field] = hash[field].force_encoding(encoding).encode('UTF-8')
      end
    end
    new({
          to: Mail::Address.new(hash[:to]),
          from: Mail::Address.new(hash[:from]),
          subject: hash[:subject],
          text: hash[:text]
        })
  end

  def source
    from.domain == 'hmps.gsi.gov.uk' ? :prison : :visitor
  end
end
