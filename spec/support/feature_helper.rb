module FeatureHelper
  def enter_prisoner_information
    visit '/'
    fill_in 'Prisoner first name', with: 'Jimmy'
    fill_in 'Prisoner last name', with: 'Fingers'
    select '1', from: 'prisoner[date_of_birth(3i)]'
    select 'May', from: 'prisoner[date_of_birth(2i)]'
    select '1969', from: 'prisoner[date_of_birth(1i)]'
    fill_in 'Prisoner number', with: 'a0000aa'
    select 'Rochester', from: 'prisoner[prison_name]'
    click_button 'Continue'
  end
end
