require 'browserstack_helper'

RSpec.feature 'visitor entering prisoner information' do
  include_examples 'feature helper'

  before(:each) { visit edit_prisoner_details_path }

  describe 'page validations' do
    context 'when a prison is not selected' do
      it 'displays an error message' do
        click_button 'Continue'

        expect(page).to have_css "label[for='prisoner_prison_name'] .validation-message"
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

    context 'when a prison that is disabled is selected' do
      let(:a_disabled_prison) { 'Rye Hill' }

      it 'displays a message about the prison being disabled' do
        set_prison_to a_disabled_prison
        click_button 'Continue'

        expect(page).to have_content 'HMP Rye Hill is unable to process online visit requests.'
      end
    end

    context 'when a prison is coming soon' do
      let(:a_prison_coming_soon) { 'Hull' }

      it 'displays a message about the prison not being available just yet' do
        set_prison_to a_prison_coming_soon
        click_button 'Continue'

        expect(page).to have_content 'HMP Hull isn’t able to process online visit requests yet.'
      end
    end

    context 'when a prison has IT issues' do
      let(:a_prison_with_it_issues) { 'Blantyre House' }

      it 'displays a message about the prison not being available just yet' do
        set_prison_to a_prison_with_it_issues
        click_button 'Continue'

        expect(page).
          to have_content 'HMP Blantyre House is unable to process online visit requests right now.'
      end
    end
  end

  scenario 'a user is taken to the vistor page when information is entered correctly' do
    enter_prisoner_information

    expect(page).to have_content('Visitor 1')
    expect(page.current_path).to eq edit_visitors_details_path
  end
end
