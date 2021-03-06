require 'poltergeist_helper'

RSpec.feature "overriding Sendgrid" do
  include ActiveJobHelper
  include FeaturesHelper

  before do
    ActionMailer::Base.deliveries.clear
  end

  let(:expected_email_address) { 'test@maildrop.dsd.io' }
  let(:irrelevant_response) { {'message' => 'success'} }

  scenario 'overriding spam report' do
    allow(SendgridApi).to receive(:spam_reported?).once.and_return(true)

    visit '/prisoner-details'
    enter_prisoner_information
    enter_visitor_information
    click_button 'Continue'

    expect(page).to have_text('marked as spam')
    check 'Tick this box to confirm you’d like us to try sending messages to you again'
    click_button 'Continue'

    expect(page).to have_content('When do you want to visit?')
    select_a_slot
    click_button 'Continue'

    expect(page).to have_content('Check your request')

    expect(SendgridApi).to receive(:remove_from_spam_list).
      with(expected_email_address).
      and_return(irrelevant_response)

    expect(SendgridApi).to_not receive(:remove_from_bounce_list)

    click_button 'Send request'

    expect(page).to have_content('Your request is being processed')
  end

  scenario 'overriding bounce' do
    allow(SendgridApi).to receive(:bounced?).once.and_return(true)

    visit '/prisoner-details'
    enter_prisoner_information
    enter_visitor_information
    click_button 'Continue'

    expect(page).to have_text('returned in the past')
    check 'Tick this box to confirm you’d like us to try sending messages to you again'
    click_button 'Continue'

    expect(page).to have_content('When do you want to visit?')
    select_a_slot
    click_button 'Continue'

    expect(page).to have_content('Check your request')

    expect(SendgridApi).to receive(:remove_from_bounce_list).
      with(expected_email_address).
      and_return(irrelevant_response)

    expect(SendgridApi).to_not receive(:remove_from_spam_list)

    click_button 'Send request'

    expect(page).to have_content('Your request is being processed')
  end

  scenario 'when no overrides are present' do
    visit '/prisoner-details'
    enter_prisoner_information
    enter_visitor_information
    click_button 'Continue'

    expect(page).to have_content('When do you want to visit?')
    select_a_slot
    click_button 'Continue'

    expect(page).to have_content('Check your request')

    expect(SendgridApi).to_not receive(:remove_from_bounce_list)
    expect(SendgridApi).to_not receive(:remove_from_spam_list)

    click_button 'Send request'

    expect(page).to have_content('Your request is being processed')
  end
end
