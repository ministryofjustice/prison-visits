require 'browserstack_helper'

feature "visitor enters prisoner information" do
  include_examples "feature helper"

  context "and leaves fields blank" do
    it "validation messages are present" do
      visit '/'

      click_button 'Continue'

      expect(page).to have_css(".validation-error #prisoner_first_name")
      expect(page).to have_css(".validation-error #prisoner_last_name")
      expect(page).to have_css(".validation-error #prisoner_date_of_birth_3i")
      expect(page).to have_css(".validation-error #prisoner_number")
      expect(page).to have_css("label[for='prisoner_prison_name'] .validation-message")
    end
  end

  context "and they fill out all fields" do
    it "prompts for visitor information" do
      visit '/'

      enter_prisoner_information

      expect(page).to have_content('Visitor 1')
    end
  end
end
