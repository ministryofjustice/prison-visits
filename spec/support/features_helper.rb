shared_examples "feature helper" do
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

  def enter_visitor_information
    within "#visitor-0" do
      fill_in "Your first name", with: 'Margaret'
      fill_in "Your last name", with: 'Smith'
      select '1', from: 'visit[visitor][][date_of_birth(3i)]'
      select 'June', from: 'visit[visitor][][date_of_birth(2i)]'
      select '1977', from: 'visit[visitor][][date_of_birth(1i)]'
      fill_in "Email address", with: 'test@example.com'
      fill_in "Contact phone number", with: '09998887777'
    end
  end

  def enter_additional_visitor_information(n, kind)
    expect(page).to have_content("Visitor #{n}")
    within "#visitor-#{n}" do
      fill_in "First name", with: 'Andy'
      fill_in "Last name", with: 'Smith'
      if kind == :adult
        select '1', from: 'visit[visitor][][date_of_birth(3i)]'
        select 'June', from: 'visit[visitor][][date_of_birth(2i)]'
        select '1977', from: 'visit[visitor][][date_of_birth(1i)]'
      else
        select '1', from: 'visit[visitor][][date_of_birth(3i)]'
        select 'August', from: 'visit[visitor][][date_of_birth(2i)]'
        select '1999', from: 'visit[visitor][][date_of_birth(1i)]'
      end
    end
  end
end
