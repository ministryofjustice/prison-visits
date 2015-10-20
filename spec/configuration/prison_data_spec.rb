require 'rails_helper'

RSpec.describe "Prison data" do
  context 'example prisons' do
    %w{ Cardiff Durham Rochester }.each do |prison|
      it "contains an enabled entry for #{prison}" do
        expect(Prison.find(prison).enabled).to be_truthy
      end
    end
  end

  context "duplicates" do
    let(:prison_names) { Prison.names }

    it "does not have duplicates" do
      expect(prison_names).to match_array(prison_names.uniq)
    end
  end

  context "enabled prisons" do
    let(:enabled) { Prison.enabled }

    it "each has a nomis_id" do
      expect(enabled.any?{ |p| p.nomis_id.blank? }).to be_falsey
    end

    it "each unbookable date for each prison should be a valid date" do
      unbookable = enabled.map(&:unbookable).flatten
      expect(unbookable.map(&:class).all?{ |p| p == Date }).to be_truthy
    end

    it "each unbookable date for each prison should be a unique" do
      enabled.each do |prison|
        expect(prison.unbookable.size).to eq(prison.unbookable.uniq.size)
      end
    end

    it "enabled prisons all have e-mail addresses" do
      expect(enabled.any?{ |p| p.email.blank? }).to be_falsey
    end

    [:phone, :email, :address, :unbookable, :slots, :enabled].each do |attribute|
      it "each prison has an #{attribute} attribute" do
        enabled.each do |prison|
          expect(prison).to respond_to(attribute)
        end
      end
    end

    it "should contain lowercase email addresses for all prisons" do
      enabled.each do |prison|
        expect(prison.email).to eq(prison.email)
      end
    end

    it "should contain slots which are 9 chars long for all prisons" do
      enabled.each do |prison|
        prison.slots.each do |_day, times|
          times.each do |time|
            expect(time).to match(/^[0-9-]{9}$/)
          end
        end
      end
    end

    it "has three character day names as keys" do
      enabled.each do |prison|
        expect(prison.slots.keys.map(&:to_s) - %w{mon tue wed thu fri sat sun}).to be_empty
      end
    end
  end
end
