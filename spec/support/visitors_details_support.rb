RSpec.shared_examples "a visitor data manipulator with valid data" do
  context "given prisoner data in the session" do
    before :each do
      controller.visit.prisoner.prison_name = 'Cardiff'
    end

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
      expect(response).to be_success
    end

    it "adds and then removes a visitor from the session" do
      get :edit
      expect {
        post :update, add_visitor_hash
        expect(response).to redirect_to controller.this_path
      }.to change { session[:visit].visitors.size }.by(1)

      expect {
        post :update, remove_visitor_hash
        expect(response).to redirect_to controller.this_path
      }.to change { session[:visit].visitors.size }.by(-1)
    end

    it "removes a visitor from the session using a hash value" do
      get :edit
      session[:visit].visitors << Visitor.new

      expect {
        post :update, remove_visitor_hash
        expect(response).to redirect_to controller.this_path
      }.to change { session[:visit].visitors.size }.by(-1)
    end
  end
end

RSpec.shared_examples "a visitor data manipulator with invalid data" do
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
      get :edit
      expect {
        post :update, bad_visitor_hash
        expect(response).to redirect_to controller.this_path
      }.not_to change { session[:visit].visitors.first.first_name }
    end
  end

  context "given too many visitors" do
    let(:visitor_hash) do
      {
        visit: {
          visitor: single_visitor_hash * 7
        },
        next: ''
      }
    end

    it "rejects the submission if there are too many visitors" do
      post :update, visitor_hash
      expect(response).to redirect_to(controller.this_path)
      expect(session[:visit].valid?(:visitors_set)).to be_falsey
    end
  end

  context "given too many adult visitors" do
    let(:visitor_hash) do
      {
        visit: {
          visitor: [
            single_visitor_hash,
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
      expect(response).to redirect_to(controller.this_path)
      expect(session[:visit].valid?(:visitors_set)).to be_falsey
    end
  end

  context "given only a single child visitor" do
    let :visitor_hash do
      {
        visit: {
          visitor: [
            first_name: 'Jack',
            last_name: 'Bauer',
            :'date_of_birth(3i)' => date_of_birth.day,
            :'date_of_birth(2i)' => date_of_birth.month,
            :'date_of_birth(1i)' => date_of_birth.year,
            email: 'user@test.example.com',
            phone: '09998887777'
          ]
        },
        next: ''
      }
    end

    context "when the prison assumes each adult to be 18 or older" do
      let :date_of_birth do
        Date.today - 18.years
      end

      it "allows the visitor to proceed" do
        post :update, visitor_hash
        expect(response).to redirect_to(controller.next_path)
      end

      context "a child applies" do
        let :date_of_birth do
          Date.today - 10.years
        end

        it "rejects the booking request" do
          post :update, visitor_hash
          expect(response).to redirect_to(controller.this_path)
        end
      end
    end

    context "when the prison assumes each adult to be some other age" do
      let :date_of_birth do
        Date.today - 18.years
      end

      before :each do
        controller.visit.prisoner.prison_name = 'Deerbolt'
      end

      it "allows the visitor to proceed" do
        post :update, visitor_hash
        expect(response).to redirect_to(controller.next_path)
      end

      context "an adult with three people over seat age threshold" do
        before :each do
          visitor_hash[:visit][:visitor] +=
            [
              {
                first_name: 'Mark',
                last_name: 'Bauer',
                :'date_of_birth(3i)' => Date.today.day,
                :'date_of_birth(2i)' => Date.today.month,
                :'date_of_birth(1i)' => Date.today.year - 10
              }
            ] * 3
        end
      end
    end
  end
end
