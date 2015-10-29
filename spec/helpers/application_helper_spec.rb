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
