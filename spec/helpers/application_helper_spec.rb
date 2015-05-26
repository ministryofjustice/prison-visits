require 'spec_helper'

describe ApplicationHelper do
  it "formats a date from a string" do
    helper.format_date('2014-07-24').should == "24 July 2014"
  end

  it "formats a date from a date" do
    helper.format_date(Date.parse('2014-07-24')).should == "24 July 2014"
  end

  it "formats a date to match NOMIS format from a string" do
    helper.format_date_nomis('2014-07-24').should == "24/07/2014"
  end

  it "formats a date to match NOMIS format from a date" do
    helper.format_date_nomis(Date.parse('2014-07-24')).should == "24/07/2014"
  end

  it "formats a day from a string" do
    helper.format_day('2014-07-24').should == "Thursday 24 July"
  end

  it "formats a day from a date" do
    helper.format_day(Date.parse('2014-07-24')).should == "Thursday 24 July"
  end

  it "formats a start time from a 24hr time string" do
    helper.display_start_time('0945').should == "9:45am"
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

  it "displays a prefix and suffix around a variable when it exists" do
    email = "visitor@example.com"
    helper.conditional_text(email, "email ", " or").should == "email visitor@example.com or"
  end

  it "displays a prefix and suffix around a number variables" do
    phone = 12345
    helper.conditional_text(phone, "call ", " or").should == "call 12345 or"
  end

  describe 'markdown' do
    it 'changes markdown to HTML' do
      source = <<-END.strip_heredoc
        para

        * list
        * item
      END
      expect(markdown(source)).to match(
        %r{\A
          <p>\s*para\s*</p>\s*
          <ul>\s*<li>\s*list\s*</li>\s*<li>\s*item\s*</li>\s*</ul>\s*
        \z}x
      )
    end

    it 'strips arbitrary HTML from input' do
      source = "<blink>It's alive!</blink>"
      expect(markdown(source)).not_to match(/<blink/)
    end
  end
end
