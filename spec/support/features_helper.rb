module FeaturesHelper
  def enter_prisoner_information(first_name: 'Jimmy', last_name: 'Harris')
    find(:css, ".ui-autocomplete-input").set('Cardiff')
    click_button 'Continue'

    fill_in 'Prisoner first name', with: first_name
    fill_in 'Prisoner last name', with: last_name
    fill_in 'prisoner[date_of_birth(3i)]', with: '1'
    fill_in 'prisoner[date_of_birth(2i)]', with: '5'
    fill_in 'prisoner[date_of_birth(1i)]', with: '1969'
    fill_in 'Prisoner number', with: 'a0000aa'
    click_button 'Continue'
  end

  def enter_visitor_information(first_name: 'Jimmy', last_name: 'Harris')
    within "#visitor-0" do
      fill_in "Your first name", with: first_name
      fill_in "Your last name", with: last_name
      fill_in 'visit[visitor][][date_of_birth(3i)]', with: '1'
      fill_in 'visit[visitor][][date_of_birth(2i)]', with: '6'
      fill_in 'visit[visitor][][date_of_birth(1i)]', with: '1977'
      fill_in "Email address", with: 'test@maildrop.dsd.io'
      fill_in "Phone number", with: '09998887777'
    end
  end

  def enter_additional_visitor_information(n, kind, first_name: 'Jimmy', last_name: 'Harris')
    within "#visitor-#{n}" do
      fill_in "First name", with: first_name
      fill_in "Last name", with: last_name
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

  def select_a_slot
    first('.BookingCalendar-date--bookable .BookingCalendar-dateLink').
      trigger('click')
    first('.SlotPicker-slot').trigger('click')
  end

  def set_prison_to(prison_name)
    find(:css, ".ui-autocomplete-input").set(prison_name)
  end
end
