require 'spec_helper'

describe VisitHelper do
  context "for the current prison" do

    let :slot do
      Slot.new(date: (Date.parse("2014-05-12")).to_s, times: "1045-1345", index: 1)
    end

    let :visit do
      Visit.new(prisoner: Prisoner.new(prison_name: "Rochester"), visitors: [Visitor.new], slots: [slot], visit_id: SecureRandom.hex)
    end

    before :each do
      helper.stub(visit: visit)
    end

    it "provides a hash of slots by day" do
      helper.visiting_slots.should == {
          :mon => [["1400", "1600"]],
          :sat => [["0930", "1130"], ["1400", "1600"]],
          :sun => [["1400", "1600"]],
          :thu => [["1400", "1600"]],
          :tue => [["1400", "1600"]],
          :wed => [["1400", "1600"]]
        }
    end

    it "provides current slots" do
      helper.current_slots.should == ["2014-05-12-1045-1345"]
    end

    it "provides the phone number" do
      helper.prison_phone.should == "01634 803100"
    end

    it "provides the email address" do
      helper.prison_email.should == "pvb.rochester@maildrop.dsd.io"
    end

    it "provides the email address" do
      helper.prison_email_link.should == '<a href="mailto:pvb.rochester@maildrop.dsd.io">pvb.rochester@maildrop.dsd.io</a>'
    end

    it "provides the postcode" do
      helper.prison_postcode.should == "ME1 3QS"
    end

    it "provides the address" do
      helper.prison_address.should start_with "1 Fort Road"
    end

    it "provides the URL" do
      helper.prison_url(visit).should include "www.justice.gov.uk/contacts/prison-finder/rochester"
    end

    it "provides the link" do
      helper.prison_link(visit).should == '<a href="http://www.justice.gov.uk/contacts/prison-finder/rochester" rel="external">Rochester prison</a>'
    end

    it "provides the slot anomalies" do
      helper.prison_slot_anomalies.should == { Date.parse("2014-08-14") => ["0700-0900"] }
    end

    it "informs when slot anomalies exist" do
      helper.has_anomalies?(Date.today).is_a? TrueClass
      helper.has_anomalies?(Date.parse("2014-08-14")).should == true
    end

    it "informs when slot anomalies exist for a particular day" do
      helper.slots_for_day(Date.parse("2014-08-13")).should == [["1400", "1600"]]
    end

    it "provides all the slots for a particular day" do
      helper.anomalies_for_day(Date.parse("2014-08-14")).should == [["0700", "0900"]]
    end

    it "provides a formatted date for when a response may be sent out" do
      helper.when_to_expect_reply(Date.parse("2014-10-03")).should == "Monday  6 October"
    end
  end

  it "should provide the prison name" do
    helper.prison_names.class.should == Array
    helper.prison_names.first.should == "Aylesbury"
  end

  it "should render custom id content for certain prisons" do
    ['Wymott',
     'Coldingley',
     'Cardiff',
     'Portland',
     'Channings Wood',
     'Dartmoor',
     'Sudbury',
     'Moorland Closed',
     'Nottingham',
     'Glen Parva',
     'Huntercombe',
     'Leicester',
     'Hindley',
     'Norwich (A, B, C, E, M only)',
     'Norwich (F, G, H, L only)',
     'Norwich (Britannia House)',
     'High Down',
     'Highpoint North',
     'Highpoint South'
    ].each do |prison_name|
      helper.custom_id_requirements(prison_name, :html).should_not be_nil
      helper.custom_id_requirements(prison_name, :text).should_not be_nil
    end
    helper.custom_id_requirements('Rochester', :html).should be_nil
    helper.custom_id_requirements('Rochester', :text).should be_nil
  end

  it "should render standard id requirements" do
    helper.standard_id_requirements(:html).should_not be_nil
    helper.standard_id_requirements(:text).should_not be_nil
  end

  it "provides the date of Monday in the current week" do
    helper.weeks_start.should == Date.today.beginning_of_week
  end

  it "provides the date the Sunday at the end of the bookable range" do
    helper.weeks_end.should == (Date.today + 28.days).end_of_month.end_of_week
  end

  it "provides the booking range grouped by the Monday of each week" do
    range = Date.today.beginning_of_week..(Date.today + 28.days).end_of_month.end_of_week
    grouped = range.group_by{|date| date.beginning_of_week}
    helper.weeks.should == grouped
  end

  it "confirms when a date is today" do
    helper.tag_with_today?(Date.today).should == true
    helper.tag_with_today?(Date.tomorrow).should == false
  end

  it "confirms when a date is the first day of a month" do
    helper.tag_with_month?(Date.parse('2014-01-01')).should == true
    helper.tag_with_month?(Date.parse('2014-01-20')).should == false
  end

  it "provides a capitalised initial of the second part of a string divided by the default token" do
    helper.last_initial('John;Smith').should == 'S.'
  end

  it "provides a capitalised initial of the second part of a string divided by a specified token" do
    helper.last_initial('Richard Dean', ' ').should == 'D.'
  end

  it "provides the first part of a string divided by the default token" do
    helper.first_name('John;Smith').should == 'John'
  end

  it "provides the first part of a string divided by a specified token" do
    helper.first_name('John Smith', ' ').should == 'John'
  end

  it "provides the second part of a string divided by the default token" do
    helper.last_name('John;Smith').should == 'Smith'
  end

  it "provides the second part of a string divided by a specified token" do
    helper.last_name('John Smith', ' ').should == 'Smith'
  end

  it "provides a list of first & last names divided by a token from visitor objects" do
    visitors = [
      Visitor.new(first_name: 'John', last_name: 'Smith'),
      Visitor.new(first_name: 'Richard', last_name: 'Dean')
    ]
    helper.visitor_names(visitors).should == ['John;Smith', 'Richard;Dean']
  end
end
