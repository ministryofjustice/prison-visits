module RandomString
  def self.random_string(length)
    letters = ('a'..'z').to_a + ('A'..'Z').to_a + [' ']
    length.times.map { letters[rand(letters.length)] }.join('')
  end
end
