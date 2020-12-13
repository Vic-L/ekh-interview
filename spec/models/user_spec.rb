require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many :loans }

  it { should validate_presence_of(:escrow) }
  it { should validate_presence_of(:amount) }

  feature 'instance methods' do
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

    feature '#account_no' do
      let!(:user) { create(:user, id: 123) }

      scenario 'should return account based on user id' do
        expect(user.account_no).to eq "EKH0000123"
      end
    end

    feature '#balance' do
      let(:user) { create(:user, amount: 123, escrow: 12) }

      scenario 'should give the difference between amount and escrow' do
        expect(user.balance).to eq 111
      end
    end

    feature '#add_to_escrow!' do
      let(:user) { create(:user, escrow: 20) }
      let(:poor_user) { create(:user, :poor) }

      scenario 'should increase escrow by the price constant' do
        expect {
          user.add_to_escrow!
        }.to change {
          user.escrow
        }.from(20)
        .to(Rails.application.config.price + 20)
      end

      scenario 'should raise error if user does not have enough funds' do
        expect {
          poor_user.add_to_escrow!
        }.to raise_error CustomException, "This user does not have enough funds to borrow the book"
      end
    end

    feature '#return!' do
      let!(:user) { create(:user) }
      let!(:loan) { create(:loan, user: user) }

      before :each do
        expect(user.reload.amount).to eq 1000
        expect(user.escrow).to eq Rails.application.config.price
      end
      
      scenario 'should reduce amount' do
        expect {
          user.return!(loan)
        }.to change {
          user.reload.amount
        }.from(1000)
        .to(1000 - Rails.application.config.price)
      end
      
      scenario 'should decrease escrow' do
        expect {
          user.return!(loan)
        }.to change {
          user.reload.escrow
        }.from(Rails.application.config.price)
        .to(0)
      end
    end
  end
end
