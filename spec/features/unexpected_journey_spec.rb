require 'rails_helper'

RSpec.feature 'unexpected journeys through the application' do
  include RackTestFeaturesHelper

  before do
    Capybara.current_driver = :rack_test
  end

  def clear_session
    # THE SHAME OF IT
    # rack-test lets us set a cookie, or clear all of them, but deleting a
    # single cookie is concealed beneath a few layers of indirection.
    page.driver.browser.current_session.
      instance_variable_get('@rack_mock_session').cookie_jar.delete 'pvbs'
  end

  def have_title(t)
    have_selector('h1', text: t)
  end

  def start_page
    edit_prisoner_details_path
  end

  before do
    visit start_page
  end

  let(:prison_name) { 'Cardiff' }

  context 'session expires' do
    scenario 'while entering prisoner details' do
      complete_prisoner_details prison_name
      clear_session
      click_button 'Continue'

      expect(page).to have_http_status(:success)
      expect(page).to have_text('Your session timed out')
      expect(page).to have_title('Who are you visiting?')
    end

    scenario 'while entering visitor details' do
      complete_prisoner_details prison_name
      click_button 'Continue'

      complete_visitor_details
      clear_session
      click_button 'Continue'

      expect(page).to have_http_status(:success)
      expect(page).to have_text('Your session timed out')
      expect(page).to have_title('Who are you visiting?')
    end

    scenario 'while entering visit details' do
      complete_prisoner_details prison_name
      click_button 'Continue'

      complete_visitor_details
      click_button 'Continue'

      complete_visit_details
      clear_session
      click_button 'Continue'

      expect(page).to have_http_status(:success)
      expect(page).to have_text('Your session timed out')
      expect(page).to have_title('Who are you visiting?')
    end

    scenario 'on the confirmation page' do
      complete_prisoner_details prison_name
      click_button 'Continue'

      complete_visitor_details
      click_button 'Continue'

      complete_visit_details
      click_button 'Continue'

      clear_session
      click_button 'Send request'

      expect(page).to have_http_status(:success)
      expect(page).to have_text('Your session timed out')
      expect(page).to have_title('Who are you visiting?')
    end
  end

  context 'skipping the prisoner step' do
    scenario 'and going to visitor details' do
      visit edit_visitors_details_path

      expect(page).to have_http_status(:success)
      expect(current_path).to eq(start_page)
      expect(page).to have_text('You need to complete missing information')
      expect(page).to have_title('Who are you visiting?')
    end

    scenario 'and going directly to visit details' do
      visit edit_slots_path

      expect(page).to have_http_status(:success)
      expect(current_path).to eq(start_page)
      expect(page).to have_text('You need to complete missing information')
      expect(page).to have_title('Who are you visiting?')
    end

    scenario 'and going directly to the confirmation page' do
      visit edit_visit_path

      expect(page).to have_http_status(:success)
      expect(current_path).to eq(start_page)
      expect(page).to have_text('You need to complete missing information')
      expect(page).to have_title('Who are you visiting?')
    end
  end
end
