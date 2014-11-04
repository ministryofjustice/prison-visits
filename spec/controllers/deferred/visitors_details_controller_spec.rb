require 'spec_helper'

describe Deferred::VisitorsDetailsController do
  render_views

  before :each do
    session[:visit] = Visit.new(visit_id: SecureRandom.hex, prisoner: Prisoner.new, visitors: [Visitor.new])
    cookies['cookies-enabled'] = 1
  end

  it_behaves_like "a browser without a session present"
  it_behaves_like "a session timed out"

  context "given prisoner data in the session" do
    let :add_visitor_hash do
      {
        visit: {
          visitor: [{}]
        },
        next: 'Add another visitor'
      }
    end

    let :remove_visitor_hash do
      {
        visit: {
          visitor: [{}, {}]
        },
        next: 'remove-1'
      }
    end

    let :remove_visitor_hash2 do
      {
        visit: {
          visitor: [{_destroy: 1}, {}]
        },
        next: ''
      }
    end

    it "displays a form for editing visitor information" do
      get :edit
      response.should be_success
    end

    it "adds and then removes a visitor from the session" do
      expect {
        post :update, add_visitor_hash
        response.should redirect_to edit_deferred_visitors_details_path
      }.to change { session[:visit].visitors.size }.by(1)

      expect {
        post :update, remove_visitor_hash
        response.should redirect_to edit_deferred_visitors_details_path
      }.to change { session[:visit].visitors.size }.by(-1)
    end

    it "removes a visitor from the session using a hash value" do
      session[:visit].visitors << Visitor.new

      expect {
        post :update, remove_visitor_hash
        response.should redirect_to edit_deferred_visitors_details_path
      }.to change { session[:visit].visitors.size }.by(-1)
    end
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
      expect {
        post :update, visitor_hash
      }.to change { session[:visit].visitors[0].first_name }
    end
  end

  context "given invalid visitor information" do
    let :bad_visitor_hash do
      {
        visit: {
          visitor: [{}]
        },
        next: ''
      }
    end
    
    it "doesn't update visitor information and redirects back to the form" do
      expect {
        post :update, bad_visitor_hash
        response.should redirect_to edit_deferred_visitors_details_path
      }.not_to change { session[:visit].visitors[0].first_name }
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
      response.should redirect_to(edit_deferred_visitors_details_path)
    end
  end

  context "given too many visitors" do
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
                   ] * 7
        },
        next: ''
      }
    end

    it "rejects the submission if there are too many visitors" do
      post :update, visitor_hash
      response.should redirect_to(edit_deferred_visitors_details_path)
      session[:visit].valid?(:visitors_set).should be_false
    end
  end

  context "given too many adult visitors" do
    let(:visitor_hash) do
      {
        visit: {
          visitor: [
                    [
                     first_name: 'Sue',
                     last_name: 'Demin',
                     :'date_of_birth(3i)' => '14',
                     :'date_of_birth(2i)' => '03',
                     :'date_of_birth(1i)' => '1986',
                     email: 'sue.denim@maildrop.dsd.io',
                     phone: '07783 123 456'
                    ],
                    [
                     first_name: 'John',
                     last_name: 'Denver',
                     :'date_of_birth(3i)' => '31',
                     :'date_of_birth(2i)' => '12',
                     :'date_of_birth(1i)' => '1943'
                    ] * 3
                   ].flatten
        },
        next: ''
      }
    end

    it "rejects the submission if there are too many adult visitors" do
      post :update, visitor_hash
      response.should redirect_to(edit_deferred_visitors_details_path)
      session[:visit].valid?(:visitors_set).should be_false
    end
  end
end
