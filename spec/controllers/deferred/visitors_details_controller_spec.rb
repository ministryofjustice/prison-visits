require 'spec_helper'

describe Deferred::VisitorsDetailsController do
  render_views

  before :each do
    session[:visit] = PrisonerDetailsController.new.new_session
    cookies['cookies-enabled'] = 1
    EmailValidator.any_instance.stub(has_mx_records: true)
  end

  it_behaves_like "a browser without a session present"
  it_behaves_like "a session timed out"
  it_behaves_like "a visitor data manipulator with valid data"
  it_behaves_like "a visitor data manipulator with invalid data"

  it "sets up the flow" do
    controller.this_path.should == deferred_edit_visitors_details_path
    controller.next_path.should == deferred_edit_slots_path
  end

  let :single_visitor_hash do
    [
     first_name: 'Sue',
     last_name: 'Demin',
     :'date_of_birth(3i)' => '14',
     :'date_of_birth(2i)' => '03',
     :'date_of_birth(1i)' => '1986',
     email: 'sue.denim@maildrop.dsd.io',
     phone: '07783 123 456'
    ]
  end

  context "given valid visitor information" do
    let(:visitor_hash) do
      {
        visit: {
          visitor: [
                    first_name: 'Sue',
                    last_name: 'Demin',
                    :'date_of_birth(3i)' => '14',
                    :'date_of_birth(2i)' => '03',
                    :'date_of_birth(1i)' => '1986',
                    email: 'sue.denim@maildrop.dsd.io',
                    phone: '07783 123 456'
                   ]
        },
        next: ''
      }
    end
    
    it "updates visitor information" do
      get :edit
      expect {
        post :update, visitor_hash
        response.should redirect_to deferred_edit_slots_path
      }.to change { session[:visit].visitors.first.first_name }
    end
  end

  context "given a visitor with two digit year component of DOB" do
    let :visitor_hash do
      {
        visit: {
          visitor: [
                    first_name: 'James',
                    last_name: 'Harris',
                    :'date_of_birth(3i)' => '5',
                    :'date_of_birth(2i)' => '3',
                    :'date_of_birth(1i)' => '12',
                    email: 'sue.denim@maildrop.dsd.io',
                    phone: '07783 123 456'
                   ]
        },
        next: ''
      }
    end

    it "rejects visitor information" do
      post :update, visitor_hash
      response.should redirect_to(deferred_edit_visitors_details_path)
    end
  end

end
