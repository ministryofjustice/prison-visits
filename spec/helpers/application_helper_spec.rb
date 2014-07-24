require 'spec_helper'

describe ApplicationHelper do
  it "formats a date" do
    helper.format_date('2014-07-24').should == "24 July 2014"
  end

  it "displays a long time" do
    helper.display_time_slot("1400-1600").should == "2:00pm to 4:00pm"
    helper.display_time_slot("0945-1145").should == "9:45am to 11:45am"
    helper.display_time_slot("1100-1200", "-").should == "11:00am-12:00pm"
  end

  it "displays a slot and duration" do
    helper.display_slot_and_duration("0945-1145").should == "9:45am, 2 hrs"
    helper.display_slot_and_duration("1430-1600").should == "2:30pm, 1 hr 30 mins"
    helper.display_slot_and_duration("1100-1200", " for ").should == "11:00am for 1 hr"
  end

  it "formats a time from a string" do
    helper.format_time_str("0900").should == "9:00am"
    helper.format_time_str("1200").should == "12:00pm"
    helper.format_time_str("1545").should == "3:45pm"
  end

  it "formats a time in 24 clock from a string" do
    helper.format_time_str_24("0900").should == "09:00"
    helper.format_time_str_24("1200").should == "12:00"
    helper.format_time_str_24("1545").should == "15:45"
  end

  it "creates a time from a string" do
    helper.time_from_str("1545").should == DateTime.now.change({:hour => 15 , :min => 45 , :sec => 0 })
  end
end
