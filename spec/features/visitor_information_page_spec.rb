require 'poltergeist_helper'

RSpec.feature "visitor enters visitor information" do
  include FeaturesHelper

  before :each do
    visit edit_prisoner_details_path
    enter_prisoner_information
  end

  context "and leaves fields blank" do
    it "validation messages are present" do
      click_button 'Continue'

      expect(page).to have_css(".validation-error #first_name_0")
      expect(page).to have_css(".validation-error #last_name_0")
      expect(page).to have_css(".validation-error #visitor_date_of_birth_day_0")
      expect(page).to have_css(".validation-error #visit_visitor__email")
      expect(page).to have_css(".validation-error #visit_visitor__phone")
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

  context "and they are defined by age" do

    it "indicates they are over the specified age for a seat" do
      enter_visitor_information

      select '1', from: 'visit[visitor][][number_of_adults]'
      enter_additional_visitor_information(1, :adult)
      fill_in "Your first name", with: 'Maggie'

      expect(page).to have_selector('.AgeLabel', :text => 'Over 18')
    end

    it "indicates they are under the specified age for a seat" do
      enter_visitor_information

      select '1', from: 'visit[visitor][][number_of_adults]'
      enter_additional_visitor_information(1, :child)
      fill_in "Your first name", with: 'Maggie'

      expect(page).to have_selector('.AgeLabel', :text => 'Under 18')
    end

  end
end
