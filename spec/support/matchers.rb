RSpec::Matchers.define :be_practically do |actual|
  match do |expected|
    expected.instance_variables.should == actual.instance_variables
    expected.instance_variables.each do |ivar|
      expected.instance_variable_get(ivar).should be_practically actual.instance_variable_get(ivar)
    end
  end
end

RSpec::Matchers.define :match_in_html do |actual|
  match do |expected|
    part = expected.body.parts.find do |part|
      part.content_type.match /text\/html/
    end
    part.should_not be_nil
    part.body.raw_source.include?(actual)
  end
end
