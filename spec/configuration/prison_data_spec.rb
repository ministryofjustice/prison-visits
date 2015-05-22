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
      expect(subject).to have_key('Rochester')
      expect(subject['Rochester']['enabled']).to be_true
      expect(Rails.configuration.prison_data).to have_key('Rochester')
    end

    it "should contain an entry for Durham" do
      expect(subject).to have_key('Durham')
      expect(subject['Durham']['enabled']).to be_true
      expect(Rails.configuration.prison_data).to have_key('Durham')
    end

    it "should contain an entry for Cardiff" do
      expect(subject).to have_key('Cardiff')
      expect(subject['Cardiff']['enabled']).to be_true
      expect(Rails.configuration.prison_data).to have_key('Cardiff')
    end

    it "should contain no duplicate prisons" do
      prisons_names = production_prison_data_as_text.reject{ |l| l.match(/^\s+/i) } # plain text as Yaml allows duplicates and uses latest
      expect(prisons_names.uniq).to eq(prisons_names)
    end
    
    context "enabled prisons" do
      let :subject do
        production_prison_data.select do |k, v|
          v['enabled']
        end
      end

      it "should each have a nomis_id" do
        subject.values.each do |prison|
          expect(prison['nomis_id']).not_to be_nil
        end
      end

      it "each unbookable date for each prison should be a valid date" do
        subject.values.each do |prison|
          prison['unbookable'].each do |d|
            expect(d).to be_a(Date)
          end
        end
      end

      it "each unbookable date for each prison should be a unique" do
        subject.values.each do |prison|
          expect(prison['unbookable'].size).to eq(prison['unbookable'].uniq.size)
        end
      end

      it "each enabled prison has a valid e-mail address" do
        subject.values.each do |prison|
          expect(Mail::Address.new(prison['email']).to_s).not_to be_empty
        end
      end

      ['phone', 'email', 'address', 'unbookable', 'slots', 'enabled'].each do |attribute|
        it "each section has a #{attribute} section" do
          subject.values.each do |prison|
            expect(prison).to have_key(attribute)
          end
        end
      end

      it "should contain lowercase email addresses for all prisons" do
        subject.values.each do |prison|
          expect(prison['email']).to eq(prison['email'].downcase)
        end
      end

      it "should contain slots which are 9 chars long for all prisons" do
        subject.values.each do |prison|
          prison['slots'].each do |day, times|
            times.each do |time|
              expect(time).to match(/^[0-9-]{9}$/)
            end
          end
        end
      end

      it "has three character day names as keys" do
        subject.values.each do |prison|
          expect(prison['slots'].keys - %w{mon tue wed thu fri sat sun}).to be_empty
        end
      end
    end
  end

  context "staging" do
    it "contains corresponding entries for every production prison" do
      while !production_prison_data.empty?
        _, p = production_prison_data.shift
        _, s = staging_prison_data.shift

        p.each_key do |k|
          next if ['email', 'enabled', 'instant_booking'].include? k
          expect(p[k]).to eq(s[k])
          if k == 'unbookable'
            expect(p[k].sort).to eq(p[k])
            expect(s[k].sort).to eq(s[k])
          end

          if k == 'slot_anomalies'
            expect(Hash[p[k].to_a.sort]).to eq(p[k])
            expect(Hash[s[k].to_a.sort]).to eq(s[k])
          end
        end
      end
    end
  end
end
