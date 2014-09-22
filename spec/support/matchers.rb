RSpec::Matchers.define :be_practically do |actual|
  match do |expected|
    expected.instance_variables.should == actual.instance_variables
    expected.instance_variables.each do |ivar|
      expected.instance_variable_get(ivar).should be_practically actual.instance_variable_get(ivar)
    end
  end
end
