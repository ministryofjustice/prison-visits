shared_examples "a visitor" do
  it "validates names" do
    visitor.tap do |v|
      v.index = 0
      v.date_of_birth = Date.parse "1986-04-20"

      v.first_name = "<Jeremy"
      v.should_not be_valid

      v.first_name = "Jeremy>"
      v.should_not be_valid

      v.first_name = "Manfred"
      v.should be_valid
    end
  end

  it "displays a full_name" do
    visitor.full_name.should == 'Otto Fibonacci'
  end

  it "returns the age of the visitor" do
    visitor.age.should == 30
    visitor.date_of_birth = nil
    visitor.age.should be_nil
  end

  (1..5).each do |i|
    it "validates every #{i}-th visitor as an additional visitor" do
      subject.tap do |v|
        v.index = i
        
        v.first_name = 'Jimmy'
        v.should_not be_valid

        v.last_name = 'Harris'
        v.should_not be_valid
        
        v.date_of_birth = Date.parse "1986-04-20"
        v.should be_valid
        
        v.email = 'anything'
        v.should_not be_valid
      end
    end
  end
end
