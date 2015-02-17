require 'browserstack_helper'

feature "visitor enters visitor information" do
  include_examples "feature helper"

  [:deferred, :instant].each do |flow|
    context "#{flow} flow" do

      before :each do
        EmailValidator.any_instance.stub(:validate_dns_records)
        EmailValidator.any_instance.stub(:validate_spam_reporter)
        EmailValidator.any_instance.stub(:validate_bounced)
        visit '/prisoner-details'
        enter_prisoner_information(flow)
      end

      context "and leaves fields blank" do
        it "validation messages are present" do
          click_button 'Continue'

          expect(page).to have_css(".validation-error #first_name_0")
          expect(page).to have_css(".validation-error #last_name_0")
          expect(page).to have_css(".validation-error #visitor_date_of_birth_3i_0")
          expect(page).to have_css(".validation-error #visit_visitor__email")
          expect(page).to have_css(".validation-error #visit_visitor__phone") if flow == :deferred
        end
      end

      context "and they fill out all fields" do
        context "for one visitor" do
          it "displays the calendar" do
            enter_visitor_information(flow)

            click_button 'Continue'

            expect(page).to have_content('When do you want to visit?')
          end
        end

        (1..5).each do |n|
          context "for #{n} additional visitors" do
            it "displays the calendar" do
              enter_visitor_information(flow)

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
          enter_visitor_information(flow)

          select '1', from: 'visit[visitor][][number_of_adults]'
          enter_additional_visitor_information(1, :adult)
          fill_in "Your first name", with: 'Maggie'

          expect(page).to have_tag('.AgeLabel', :text => 'Over 18')
        end

        it "indicates they are under the specified age for a seat" do
          enter_visitor_information(flow)

          select '1', from: 'visit[visitor][][number_of_adults]'
          enter_additional_visitor_information(1, :child)
          fill_in "Your first name", with: 'Maggie'

          expect(page).to have_tag('.AgeLabel', :text => 'Under 18')
        end

      end
    end
  end
end
