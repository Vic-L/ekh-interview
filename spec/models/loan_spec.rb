require 'rails_helper'

RSpec.describe Loan, type: :model do
  it { should belong_to :user }
  it { should belong_to(:book).counter_cache(true) }

  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:borrow_at) }

  feature 'callback' do
    feature '.reduce_book_availability' do
      let(:book) { create(:book) }
      let(:unavailable_book) { create(:book, :unavailable) }

      scenario 'should reduce book quantity by 1 upon creation' do
        expect { create(:loan, book: book) }.to change {
          book.quantity
        }.from(10)
        .to(9)
      end

      scenario 'should raise error if book is no longer available' do
        expect { create(:loan, book: unavailable_book) }.to raise_error CustomException, "This book is no longer available"
      end
    end

    feature '.increase_user_escrow upon creation' do
      let(:book) { create(:book) }
      let(:poor_user) { create(:user, :poor) }

      scenario 'should increase user escrow' do
        expect {
          create(:loan, book: book, user: poor_user)
        }.to raise_error CustomException, "This user does not have enough funds to borrow the book"
      end
    end
  end

  feature 'scope' do
    feature '.active' do
      let!(:active_loan) { create(:loan) }
      let!(:returned_loan) { create(:loan, :returned) }

      scenario 'should return only loans that have not been returned' do
        expect(Loan.active.count).to eq 1
        expect(Loan.active.first.id).to eq active_loan.id
      end
    end

    feature '.past' do
      let!(:active_loan) { create(:loan) }
      let!(:returned_loan) { create(:loan, :returned) }

      scenario 'should return only loans that have been returned' do
        expect(Loan.past.count).to eq 1
        expect(Loan.past.first.id).to eq returned_loan.id
      end
    end
  end

  feature 'instance methods' do
    feature '#return!' do
      let!(:user) { create(:user) }
      let!(:book) { create(:book) }
      let!(:loan) { create(:loan, user: user, book: book) }

      scenario 'should update return_at' do
        expect { loan.return! }.to change { loan.reload.return_at }
      end

      scenario 'should increase book quantity' do
        expect { loan.return! }.to change {
          book.reload.quantity
        }.from(9)
        .to(10)
      end

      scenario 'should decrease user escrow by loan amount' do
        loan.update(amount: Rails.application.config.price - 1)
        expect(loan.amount).not_to eq Rails.application.config.price

        expect { loan.return! }.to change {
          user.reload.escrow
        }.from(Rails.application.config.price)
        .to(1)
      end
    end
  end
end
