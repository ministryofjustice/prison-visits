require 'spec_helper'

describe "Prison data" do
  let :production_prison_data do
    YAML.load_file(File.join(Rails.root, "config", "prison_data_production.yml"))
  end

  let :staging_prison_data do
    YAML.load_file(File.join(Rails.root, "config", "prison_data_staging.yml"))
  end

  let :production_prison_data_as_text do
    File.readlines(File.join(Rails.root, "config", "prison_data_production.yml"))
  end

  context "production" do
    let :subject do
      production_prison_data
    end

    it "should contain an entry for Rochester" do
      subject.should have_key('Rochester')
      subject['Rochester']['enabled'].should be_true
      Rails.configuration.prison_data.should have_key('Rochester')
    end

    it "should contain an entry for Durham" do
      subject.should have_key('Durham')
      subject['Durham']['enabled'].should be_true
      Rails.configuration.prison_data.should have_key('Durham')
    end

    it "should contain an entry for Cardiff" do
      subject.should have_key('Cardiff')
      subject['Cardiff']['enabled'].should be_true
      Rails.configuration.prison_data.should have_key('Cardiff')
    end

    it "each unbookable date for each prison should be a valid date" do
      subject.values.each do |prison|
        prison['unbookable'].each do |d|
          d.should be_a(Date)
        end
      end
    end

    it "each enabled prison has a valid e-mail address" do
      subject.values.each do |prison|
        Mail::Address.new(prison['email']).to_s.should_not be_empty if prison['enabled']
      end
    end

    ['phone', 'email', 'address', 'unbookable', 'slots', 'enabled'].each do |attribute|
      it "each section has a #{attribute} section" do
        subject.values.each do |prison|
          prison.should have_key(attribute)
        end
      end
    end

    it "should contain lowercase email addresses for all prisons" do
      subject.values.each do |prison|
        prison['email'].should match(/^[a-z0-9@\.-]+$/)
      end
    end

    it "should contain slots which are 9 chars long for all prisons" do
      subject.values.each do |prison|
        prison['slots'].each do |day, times|
          times.each do |time|
            time.should match(/^[0-9-]{9}$/)
          end
        end
      end
    end

    it "should contain no duplicate prisons" do
      prisons_names = production_prison_data_as_text.reject{ |l| l.match(/^\s+/i) } # plain text as Yaml allows duplicates and uses latest
      prisons_names.detect{ |e| prisons_names.count(e) > 1 }.should be(nil)
    end
  end

  context "staging" do
    it "contains corresponding entries for every production prison" do
      while !production_prison_data.empty?
        _, p = production_prison_data.shift
        _, s = staging_prison_data.shift

        p.each_key do |k|
          next if ['email','enabled'].include? k
          p[k].should == s[k]
        end
      end
    end
  end
end
