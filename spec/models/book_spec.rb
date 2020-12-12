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
      let!(:book) { create(:book) }

      scenario 'should raise error if available_count is already 0' do
        book.update(available_count: 0)
        expect(book.reload.available_count).to eq 0
        expect { book.subtract_available_count! }.to raise_error "This book is no longer available"
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
