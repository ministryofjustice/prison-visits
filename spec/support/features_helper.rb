module FeaturesHelper
  def enter_prisoner_information
    fill_in 'Prisoner first name', with: 'Jimmy'
    fill_in 'Prisoner last name', with: 'Harris'
    fill_in 'prisoner[date_of_birth(3i)]', with: '1'
    fill_in 'prisoner[date_of_birth(2i)]', with: '5'
    fill_in 'prisoner[date_of_birth(1i)]', with: '1969'
    fill_in 'Prisoner number', with: 'a0000aa'
    find(:css, ".ui-autocomplete-input").set('Rochester')
    click_button 'Continue'
  end

  def enter_visitor_information
    within "#visitor-0" do
      fill_in "Your first name", with: 'Margaret'
      fill_in "Your last name", with: 'Smith'
      fill_in 'visit[visitor][][date_of_birth(3i)]', with: '1'
      fill_in 'visit[visitor][][date_of_birth(2i)]', with: '6'
      fill_in 'visit[visitor][][date_of_birth(1i)]', with: '1977'
      fill_in "Email address", with: 'test@maildrop.dsd.io'
      fill_in "Contact phone number", with: '09998887777'
    end
  end

  def enter_additional_visitor_information(n, kind)
    within "#visitor-#{n}" do
      fill_in "First name", with: 'Andy'
      fill_in "Last name", with: 'Smith'
      if kind == :adult
        fill_in 'visit[visitor][][date_of_birth(3i)]', with: '1'
        fill_in 'visit[visitor][][date_of_birth(2i)]', with: '6'
        fill_in 'visit[visitor][][date_of_birth(1i)]', with: '1977'
      else
        fill_in 'visit[visitor][][date_of_birth(3i)]', with: '1'
        fill_in 'visit[visitor][][date_of_birth(2i)]', with: '8'
        fill_in 'visit[visitor][][date_of_birth(1i)]', with: '1999'
      end
    end
  end
end

shared_examples "feature helper" do
  include FeaturesHelper
end
