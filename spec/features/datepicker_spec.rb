require 'spec_helper'

feature "visitor selects a date" do
  before :each do
    BookingRequest.any_instance.stub(:sender).and_return('lol@biz.info')
    BookingConfirmation.any_instance.stub(:sender).and_return('lol@biz.info')
    enter_prisoner_information
    enter_visitor_information
    click_button 'Continue'
  end

  context "that is unbookable" do
    it "and displays a message saying booking is not possible" do
      tomorrow = Time.now + 1.day
      find(:xpath, tomorrow.strftime("//a[@data-date='%Y-%m-%d']")).click
      page.should have_content('You can only book a visit 3 days in advance.')

      a_month_from_now = Time.now + 1.month + 1.day
      find(:xpath, a_month_from_now.strftime("//a[@data-date='%Y-%m-%d']")).click
      page.should have_content('You can only book a visit in the next 28 days.')
    end
  end

  context "that is bookable" do
    it "displays booking slots" do
      three_days_from_now = Time.now + 3.days
      find(:xpath, three_days_from_now.strftime("//a[@data-date='%Y-%m-%d']")).click
      page.should have_content(three_days_from_now.strftime("%A %e %B"))
      check("slot-#{three_days_from_now.strftime('%Y-%m-%d')}-1400-1600")
      click_button 'Continue'

      page.should have_content('Check your request')

      click_button 'Send request'
      page.should have_content('Your visit request has been sent')
    end
  end
end
