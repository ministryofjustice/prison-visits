shared_examples "a visitor" do
  it "validates names" do
    visitor.tap do |v|
      v.index = 0
      v.date_of_birth = Date.parse "1986-04-20"

      v.first_name = "<Jeremy"
      expect(v).not_to be_valid

      v.first_name = "Jeremy>"
      expect(v).not_to be_valid

      v.first_name = "Manfred"
      expect(v).to be_valid
    end
  end

  it "displays a full_name" do
    expect(visitor.full_name).to eq('Otto Fibonacci')
  end

  it "returns the age of the visitor" do
    expect(visitor.age).to eq(30)
    visitor.date_of_birth = nil
    expect(visitor.age).to be_nil
  end

  (1..5).each do |i|
    it "validates every #{i}-th visitor as an additional visitor" do
      subject.tap do |v|
        v.index = i

        v.first_name = 'Jimmy'
        expect(v).not_to be_valid

        v.last_name = 'Harris'
        expect(v).not_to be_valid

        v.date_of_birth = Date.parse "1986-04-20"
        expect(v).to be_valid

        v.email = 'anything'
        expect(v).not_to be_valid
      end
    end
  end
end
