require 'browserstack_helper'

feature "visitor enters visitor information" do
  include_examples "feature helper"

  before :each do
    EmailValidator.any_instance.stub(:has_mx_records).and_return(true)
    visit '/prisoner-details'
    enter_prisoner_information(:deferred)
  end

  context "and leaves fields blank" do
    it "validation messages are present" do
      click_button 'Continue'

      expect(page).to have_css(".validation-error #first_name_0")
      expect(page).to have_css(".validation-error #last_name_0")
      expect(page).to have_css(".js-native-date .validation-message")
      expect(page).to have_css(".validation-error #visit_visitor__email")
      expect(page).to have_css(".validation-error #visit_visitor__phone")
    end
  end

  context "and they fill out all fields" do
    context "for one visitor" do
      it "displays the calendar" do
        enter_visitor_information(:deferred)

        click_button 'Continue'

        expect(page).to have_content('When do you want to visit?')
      end
    end

    (1..5).each do |n|
      context "for #{n} additional visitors" do
        it "displays the calendar" do
          enter_visitor_information(:deferred)

          select n.to_s, from: 'visit[visitor][][number_of_adults]'
          (1..n).each do |m|
            enter_additional_visitor_information(m, m < 3 ? :adult : :child)
          end

          click_button 'Continue'
          expect(page).to have_content('When do you want to visit?')
        end
      end
    end
  end
end
