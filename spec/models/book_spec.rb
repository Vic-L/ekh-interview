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

    feature '#subtract_available_count!' do
      let(:book) { create(:book) }
      let(:out_of_stock_book) { create(:book, :out_of_stock) }
      let(:unavailable_book) { create(:book, :unavailable) }

      scenario 'should raise error if quantity is 0' do
        expect { out_of_stock_book.subtract_available_count! }.to raise_error CustomException, "This book has been given away"
      end

      scenario 'should raise error if available_count is already 0' do
        expect { unavailable_book.subtract_available_count! }.to raise_error CustomException, "This book is no longer available"
      end

      scenario 'should reduce available_count by 1' do
        expect { book.subtract_available_count! }.to change {
          book.available_count
        }.from(10)
        .to (9)
      end
    end

    feature '#increment_available_count!' do
      let!(:book) { create(:book) }

      scenario 'should increase available_count by 1' do
        expect { book.increment_available_count! }.to change {
          book.available_count
        }.from(10)
        .to (11)
      end
    end
  end
end
