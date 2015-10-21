require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#prison_estate_name_for_id' do
    it 'returns a prison name for a nomis id' do
      expect(helper.prison_estate_name_for_id('RCI')).to eq('Rochester')
    end

    it 'returns nil for a bad nomis id' do
      expect(helper.prison_estate_name_for_id('Bad Id')).to be_nil
    end
  end

  it "formats a start time from a 24hr time string" do
    expect(helper.display_start_time('0945')).to eq("9:45am")
  end

  it "displays a slot and duration" do
    expect(helper.display_slot_and_duration("0945-1145")).to eq("9:45am for 2 hrs")
    expect(helper.display_slot_and_duration("1430-1600")).to eq("2:30pm for 1 hr 30 mins")
  end

  it "formats a time from a string" do
    expect(helper.format_time_str("0900")).to eq("9:00am")
    expect(helper.format_time_str("1200")).to eq("12:00pm")
    expect(helper.format_time_str("1545")).to eq("3:45pm")
  end

  it "formats a time in 24 clock from a string" do
    expect(helper.format_time_str_24("0900")).to eq("09:00")
    expect(helper.format_time_str_24("1200")).to eq("12:00")
    expect(helper.format_time_str_24("1545")).to eq("15:45")
  end

  it "creates a time from a string" do
    expect(helper.time_from_string("1545")).to eq(DateTime.now.change({ hour: 15, min: 45, sec: 0 }))
  end

  it "displays a prefix and suffix around a variable when it exists" do
    email = "visitor@example.com"
    expect(helper.conditional_text(email, "email ", " or")).to eq("email visitor@example.com or")
  end

  it "displays a prefix and suffix around a number variables" do
    phone = 12345
    expect(helper.conditional_text(phone, "call ", " or")).to eq("call 12345 or")
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
