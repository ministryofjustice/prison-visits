require 'browserstack_helper'

feature "visitor enters prisoner information" do
  include_examples "feature helper"

  context "and leaves fields blank" do
    it "validation messages are present when a prison is not selected" do
      visit '/prisoner-details'

      click_button 'Continue'

      expect(page).to have_css("label[for='prisoner_prison_name'] .validation-message")
    end

    it "validation messages are present" do
      visit '/prisoner-details'

      find(:css, ".ui-autocomplete-input").set('Cardiff')
      click_button 'Continue'

      expect(page).to have_css(".field_with_errors #prisoner_first_name")
      expect(page).to have_css(".field_with_errors #prisoner_last_name")
      expect(page).to have_css(".js-native-date.validation-error")
      expect(page).to have_css(".field_with_errors #prisoner_number")
    end
  end

  context "and they fill out all fields" do
    it "prompts for visitor information" do
      visit '/prisoner-details'

      enter_prisoner_information(:deferred)

      expect(page).to have_content('Visitor 1')
    end
  end
end
