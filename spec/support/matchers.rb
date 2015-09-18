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
    html_part = expected.body.parts.find do |part|
      part.content_type.match(/text\/html/)
    end
    expect(html_part).not_to be_nil
    html_part.body.raw_source.include?(actual)
  end
end

RSpec::Matchers.define :match_in_text do |actual|
  match do |expected|
    text_part = expected.body.parts.find do |part|
      part.content_type.match(/text\/plain/)
    end

    if text_part
      expect(text_part).not_to be_nil
      text_part.body.raw_source.include?(actual)
    else
      expected.body.raw_source.include?(actual)
    end
  end
end

RSpec::Matchers.define :same_visit do |v|
  match { |actual| v.same_visit?(actual) }
end
