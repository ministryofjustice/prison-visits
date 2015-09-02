RSpec.shared_examples 'a visitor' do
  before do
    subject.index = 0
  end

  describe 'validation' do
    context 'first name' do
      it 'is invalid if it contains punctuation' do
        subject.first_name = '<Jeremy'
        subject.validate
        expect(subject.errors[:first_name]).not_to be_empty
      end

      it 'is valid if it contains an ASCII apostrophe' do
        subject.first_name = "O'Dear"
        subject.validate
        expect(subject.errors[:first_name]).to be_empty
      end

      it 'is valid if it contains a unicode apostrophe' do
        subject.first_name = 'O’Dear'
        subject.validate
        expect(subject.errors[:first_name]).to be_empty
      end
    end

    context 'last name' do
      it 'is invalid if it contains punctuation' do
        subject.last_name = '<Odear'
        subject.validate
        expect(subject.errors[:last_name]).not_to be_empty
      end

      it 'is valid if it contains an ASCII apostrophe' do
        subject.last_name = "O'Dear"
        subject.validate
        expect(subject.errors[:last_name]).to be_empty
      end

      it 'is valid if it contains a unicode apostrophe' do
        subject.last_name = 'O’Dear'
        subject.validate
        expect(subject.errors[:last_name]).to be_empty
      end
    end

    context 'email' do
      context 'for the first visitor' do
        before do
          subject.index = 0
        end

        it 'is invalid without an email' do
          subject.email = nil
          subject.validate
          expect(subject.errors[:email]).not_to be_empty
        end

        it 'is valid with an email' do
          subject.email = 'user@test.example.com'
          subject.validate
          expect(subject.errors[:email]).to be_empty
        end
      end

      context 'for an additional visitor' do
        before do
          subject.index = 1
        end

        it 'is valid without an email' do
          subject.email = nil
          subject.validate
          expect(subject.errors[:email]).to be_empty
        end

        it 'is invalid with an email' do
          subject.email = 'user@test.example.com'
          subject.validate
          expect(subject.errors[:email]).not_to be_empty
        end
      end
    end

    context 'date of birth' do
      it 'is valid when in a reasonable range' do
        subject.date_of_birth = Date.new(1970, 1, 1)
        subject.validate
        expect(subject.errors[:date_of_birth]).to be_empty
      end

      it 'is invalid when outside a reasonable range' do
        subject.date_of_birth = Date.new(1770, 1, 1)
        subject.validate
        expect(subject.errors[:date_of_birth]).to eq(['must be a valid date'])
      end

      it 'is invalid when missing' do
        subject.date_of_birth = nil
        subject.validate
        expect(subject.errors[:date_of_birth]).to eq(['must be a valid date'])
      end
    end
  end

  it 'forms full name' do
    subject.first_name = 'Otto'
    subject.last_name = 'Fibonacci'
    expect(subject.full_name).to eq('Otto Fibonacci')
  end

  it 'generates an initial from the last name' do
    subject.last_name = 'Fibonacci'
    expect(subject.last_initial).to eq('F')
  end

  describe 'age' do
    before do
      subject.date_of_birth = Date.new(1980, 6, 1)
    end

    it 'is calculated on the day before the birthday' do
      Timecop.freeze(Date.new(2015, 5, 31)) do
        expect(subject.age).to eq(34)
      end
    end

    it 'is calculated on the day after the birthday' do
      Timecop.freeze(Date.new(2015, 6, 2)) do
        expect(subject.age).to eq(35)
      end
    end

    it 'is calculated on the birthday' do
      Timecop.freeze(Date.new(2015, 6, 1)) do
        expect(subject.age).to eq(35)
      end
    end
  end
end
