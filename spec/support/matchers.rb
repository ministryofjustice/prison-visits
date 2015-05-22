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
    expect(part).not_to be_nil
    part.body.raw_source.include?(actual)
  end
end

RSpec::Matchers.define :match_in_text do |actual|
  match do |expected|
    if part = expected.body.parts.find do |part|
        part.content_type.match /text\/plain/
      end
      expect(part).not_to be_nil
      part.body.raw_source.include?(actual)
    else
      expected.body.raw_source.include?(actual)
    end
  end
end
