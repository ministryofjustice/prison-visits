require 'spec_helper'

feature "visitor enters visitor information" do
  include_examples "feature helper"

  before :each do
    visit '/'
    enter_prisoner_information
  end

  context "and leaves fields blank" do
    it "validation messages are present" do
      click_button 'Continue'

      expect(page).to have_css(".field_with_errors #first_name_0")
      expect(page).to have_css(".field_with_errors #last_name_0")
      expect(page).to have_css("label[for='visitor_date_of_birth_3i'] .validation-message")
      expect(page).to have_css(".field_with_errors #visit_visitor__email")
      expect(page).to have_css(".field_with_errors #visit_visitor__phone")
    end
  end

  context "and they fill out all fields" do
    context "for one visitor" do
      it "displays the calendar" do
        enter_visitor_information

        click_button 'Continue'

        expect(page).to have_content('When do you want to visit?')
      end
    end

    (1..5).each do |n|
      context "for #{n} additional visitors" do
        it "displays the calendar" do
          enter_visitor_information

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
