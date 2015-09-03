require 'rails_helper'

RSpec.describe VisitHelper, type: :helper do
  module ControllerContext
    def visit
    end
  end

  context "for the current prison" do

    let :slot do
      Slot.new(date: (Date.parse("2014-05-12")).to_s, times: "1045-1345", index: 1)
    end

    let :visit do
      Visit.new(prisoner: Prisoner.new(prison_name: "Rochester"), visitors: [Visitor.new], slots: [slot], visit_id: SecureRandom.hex)
    end

    before :each do
      helper.extend ControllerContext
      allow(helper).to receive(:visit).and_return(visit)
    end

    it "provides a hash of slots by day" do
      allow(Rails.configuration.prison_data['Rochester']).
        to receive(:[]).with('slots') { {
            mon: ['1400-1600'],
            tue: ['1400-1600'],
            wed: ['1400-1600'],
            thu: ['1400-1600'],
            sat:[
              '0930-1130',
              '1400-1600',
            ],
            sun: ['1400-1600'],
        } }
      expect(helper.visiting_slots).to eq({
          :mon => [["1400", "1600"]],
          :tue => [["1400", "1600"]],
          :wed => [["1400", "1600"]],
          :thu => [["1400", "1600"]],
          :sat => [
            ["0930", "1130"],
            ["1400", "1600"],
          ],
          :sun => [["1400", "1600"]],
        })
    end

    it "provides current slots" do
      expect(helper.current_slots).to eq(["2014-05-12-1045-1345"])
    end

    it 'provides the prisons name' do
      expect(helper.prison_name).to eq('Rochester')
    end

    it "provides the phone number" do
      expect(helper.prison_phone).to eq("01634 803100")
    end

    it "provides the email address" do
      expect(helper.prison_email).to eq("pvb.rochester@maildrop.dsd.io")
    end

    it "provides the email address" do
      expect(helper.prison_email_link).to eq('<a href="mailto:pvb.rochester@maildrop.dsd.io">pvb.rochester@maildrop.dsd.io</a>')
    end

    it "provides the postcode" do
      expect(helper.prison_postcode).to eq("ME1 3QS")
    end

    it "provides the address" do
      expect(helper.prison_address).to start_with "1 Fort Road"
    end

    it "escapes html in the address" do
      allow(Rails.configuration.prison_data['Rochester']).
        to receive(:[]).with('address') { ['Danger<script>ous']}

      expect(helper.prison_address).not_to match(/<script/)
    end

    it "joins address lines with br" do
      allow(Rails.configuration.prison_data['Rochester']).
        to receive(:[]).with('address') { ['hello', 'hey'] }

      expect(helper.prison_address).to eq('hello<br>hey')
    end

    it "provides the URL" do
      expect(helper.prison_url(visit)).to include "www.justice.gov.uk/contacts/prison-finder/rochester"
    end

    it "provides the link" do
      link = helper.prison_link(visit)
      expect(link).to match(%r{<a[^>]+>Rochester prison</a>})
      expect(link).to match(%r{href="http://www\.justice\.gov\.uk/contacts/prison-finder/rochester"})
    end

    it "provides the slot anomalies" do
      expect(helper.prison_slot_anomalies).to eq({ Date.parse("2014-08-14") => ["0700-0900"] })
    end

    it "informs when slot anomalies exist" do
      helper.has_anomalies?(Date.today).is_a? TrueClass
      expect(helper.has_anomalies?(Date.parse("2014-08-14"))).to eq(true)
    end

    it "informs when slot anomalies exist for a particular day" do
      expect(helper.slots_for_day(Date.parse("2014-08-13"))).to eq([["1400", "1600"]])
    end

    it "provides all the slots for a particular day" do
      expect(helper.anomalies_for_day(Date.parse("2014-08-14"))).to eq([["0700", "0900"]])
    end

    it "provides a formatted date for when a response may be sent out" do
      Timecop.travel(Date.parse("2014-10-03")) do
        expect(helper.when_to_expect_reply).to eq("Monday 6 October")
      end
    end
  end

  it "should provide the prison name" do
    expect(helper.prison_names.class).to eq(Array)
    expect(helper.prison_names.first).to eq("Acklington")
  end

  describe 'prison_specific_id_requirements' do
    it 'should render custom id content for prisons that have it' do
      requirements = helper.prison_specific_id_requirements('Wymott')
      expect(requirements).to match(/tenancy agreement/)
    end

    it 'should render standard id content for prisons that do not have custom content' do
      requirements = helper.prison_specific_id_requirements('Rochester')
      expect(requirements).not_to match(/tenancy agreement/)
      expect(requirements).to match(/driving licence/)
    end
  end

  it "provides the date of Monday in the current week" do
    expect(helper.weeks_start).to eq(Date.today.beginning_of_week)
  end

  it "provides the date the Sunday at the end of the bookable range" do
    expect(helper.weeks_end).to eq((Date.today + 28.days).end_of_month.end_of_week)
  end

  it "provides the booking range grouped by the Monday of each week" do
    range = Date.today.beginning_of_week..(Date.today + 28.days).end_of_month.end_of_week
    grouped = range.group_by{|date| date.beginning_of_week}
    expect(helper.weeks).to eq(grouped)
  end

  it "confirms when a date is today" do
    expect(helper.tag_with_today?(Date.today)).to eq(true)
    expect(helper.tag_with_today?(Date.tomorrow)).to eq(false)
  end

  it "confirms when a date is the first day of a month" do
    expect(helper.tag_with_month?(Date.parse('2014-01-01'))).to eq(true)
    expect(helper.tag_with_month?(Date.parse('2014-01-20'))).to eq(false)
  end

  it "provides a capitalised initial of the second part of a string divided by the default token" do
    expect(helper.last_initial('John;Smith')).to eq('S.')
  end

  it "provides a capitalised initial of the second part of a string divided by a specified token" do
    expect(helper.last_initial('Richard Dean', ' ')).to eq('D.')
  end

  it "provides the first part of a string divided by the default token" do
    expect(helper.first_name('John;Smith')).to eq('John')
  end

  it "provides the first part of a string divided by a specified token" do
    expect(helper.first_name('John Smith', ' ')).to eq('John')
  end

  it "provides the second part of a string divided by the default token" do
    expect(helper.last_name('John;Smith')).to eq('Smith')
  end

  it "provides the second part of a string divided by a specified token" do
    expect(helper.last_name('John Smith', ' ')).to eq('Smith')
  end

  it "provides a list of first & last names divided by a token from visitor objects" do
    visitors = [
      Visitor.new(first_name: 'John', last_name: 'Smith'),
      Visitor.new(first_name: 'Richard', last_name: 'Dean')
    ]
    expect(helper.visitor_names(visitors)).to eq(['John;Smith', 'Richard;Dean'])
  end
end
