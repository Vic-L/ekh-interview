require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many :loans }

  it { should validate_presence_of(:escrow) }
  it { should validate_presence_of(:amount) }

  feature 'callback' do
    scenario 'should generate account_no upon creation' do
      user = User.create(amount: 1000, escrow: 0)
      expect(user.account_no).to eq "EKH#{user.id.to_s.rjust(7, '0')}"
    end

    scenario 'should generate account_no based on id' do
      user = User.create(amount: 1000, escrow: 0, id: 123)
      expect(user.account_no).to eq "EKH0000123"
    end
  end

  feature 'instance methods' do
    feature '#current_loans' do
      let!(:user_with_books) { create(:user, :with_books) }

      scenario 'should return only loans that are active' do
        expect(user_with_books.loans.count).to eq 4
        expect(user_with_books.current_loans.count).to eq 2
        expect(user_with_books.current_loans.pluck(:return_at).compact.count).to eq 0 # all have nil values
      end
    end

    feature '#current_borrowed_books' do
      let!(:user_with_books) { create(:user, :with_books) }
      let!(:another_user_with_books) { create(:user, :with_books) }

      scenario 'should return only books that are currently borrowed' do
        borrowed_book_ids = Loan.where(user_id: user_with_books.id).active.pluck(:book_id)

        expect(borrowed_book_ids.length).to eq user_with_books.current_borrowed_books.length
        expect(user_with_books.current_borrowed_books.pluck(:id) - borrowed_book_ids).to eq []
      end

      scenario 'should only return books belonging to user' do
        borrowed_book_ids_by_another_user = Loan.where(user_id: another_user_with_books.id).active.pluck(:book_id)

        expect(user_with_books.current_borrowed_books.pluck(:id) - borrowed_book_ids_by_another_user).to eq user_with_books.current_borrowed_books.pluck(:id)
      end
    end
  end
end
