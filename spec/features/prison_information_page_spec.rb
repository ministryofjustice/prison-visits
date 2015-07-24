require 'browserstack_helper'

RSpec.feature 'visitor entering prisoner information' do
  include_examples 'feature helper'

  before(:each) { visit '/prisoner-details' }

  %i<deferred instant>.each do |flow|
    describe "#{flow} flow" do
      describe 'page validations' do
        context 'when a prison is not selected' do
          it 'displays an error message' do
            click_button 'Continue'
            expect(page).to have_css("label[for='prisoner_prison_name'] .validation-message")
          end
        end

        context 'when prisoner related form fields are left blank' do
          let(:prisoner_element_ids) { %w<first_name last_name date_of_birth_3i number> }

          it 'displays error messages for each field' do
            set_prison_to 'Cardiff'
            click_button 'Continue'
            prisoner_element_ids.each do |id|
              expect(page).to have_css ".validation-error #prisoner_#{id}"
            end
          end
        end
      end

      scenario 'user is taken to the vistor page when information is entered correctly' do
        enter_prisoner_information(flow)

        expect(page).to have_content('Visitor 1')
        expect(page.current_path).to eq "/#{flow}/visitors"
      end
    end
  end
end
