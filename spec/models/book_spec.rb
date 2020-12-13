require 'rails_helper'

RSpec.describe Book, type: :model do
  it { should have_many :loans }

  feature 'instance methods' do
    feature 'current_loans' do
      let!(:book) { create(:book) }
      let!(:loan) { create(:loan, book: book) }
      let!(:returned_loan) { create(:loan, :returned, book: book) }

      scenario 'should return only loans that are active' do
        expect(book.current_loans.count).to eq 1
        expect(book.current_loans.first.id).to eq loan.id
      end
    end

    feature '#subtract_quantity!' do
      let(:book) { create(:book) }
      let(:unavailable_book) { create(:book, :unavailable) }

      scenario 'should raise error if quantity is already 0' do
        expect { unavailable_book.subtract_quantity! }.to raise_error CustomException, "This book is no longer available"
      end

      scenario 'should reduce quantity by 1' do
        expect { book.subtract_quantity! }.to change {
          book.quantity
        }.from(10)
        .to (9)
      end
    end

    feature '#increment_quantity!' do
      let!(:book) { create(:book) }

      scenario 'should increase quantity by 1' do
        expect { book.increment_quantity! }.to change {
          book.quantity
        }.from(10)
        .to (11)
      end
    end

    feature '#borrow_count' do
      let!(:book) { create(:book) }
      let!(:user) { create(:user) }
      let!(:another_user) { create(:user) }
      let!(:loan1) { create(:loan, book: book, user: user) }
      let!(:loan2) { create(:loan, book: book, user: user) }
      let!(:another_loan1) { create(:loan, book: book, user: another_user) }

      scenario 'should return the number of copies of the book the user is currently loaning' do
        expect(book.borrow_count(user)).to eq 2
        expect(book.borrow_count(another_user)).to eq 1
      end
    end
  end
end
