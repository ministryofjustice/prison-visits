require 'spec_helper'

describe "Prison data" do
  let :subject do
    YAML.load_file(File.join(Rails.root, "config", "prison_data.yml"))
  end

  it "should contain an entry for Rochester" do
    subject.should have_key('Rochester')
    subject['Rochester']['enabled'].should be_true
    Rails.configuration.prison_data.should have_key('Rochester')

    subject['Rochester']['unbookable'].should == ['2013-12-25', '2013-12-26', '2014-12-25', '2014-12-26'].map { |d| Date.parse(d) }
  end

  it "should contain an entry for Durham" do
    subject.should have_key('Durham')
    subject['Durham']['enabled'].should be_false
    Rails.configuration.prison_data.should_not have_key('Durham')

    subject['Durham']['unbookable'].should == ['2014-04-18', '2014-04-20', '2014-12-25', '2014-12-26', '2015-01-01'].map { |d| Date.parse(d) }
  end

  it "should contain an entry for Cardiff" do
    subject.should have_key('Cardiff')
    subject['Cardiff']['enabled'].should be_false
    Rails.configuration.prison_data.should_not have_key('Cardiff')

    subject['Cardiff']['unbookable'].should == ['2014-04-20', '2014-12-25', '2014-12-26', '2015-01-01'].map { |d| Date.parse(d) }
  end

  ['phone', 'email', 'address', 'unbookable', 'slots', 'enabled'].each do |attribute|
    it "each section has a #{attribute} section" do
      subject.values.each do |prison|
        prison.should have_key(attribute)
      end
    end
  end
end
