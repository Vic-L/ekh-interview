require 'rails_helper'

RSpec.describe Loan, type: :model do
  it { should belong_to :user }
  it { should belong_to(:book).counter_cache(true) }

  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:borrow_at) }

  feature 'callback' do
    feature '.reduce_book_availability' do
      let!(:book) { create(:book) }

      scenario 'should reduce book available_count by 1 upon creation' do
        expect { create(:loan, book: book) }.to change {
          book.available_count
        }.from(10)
        .to(9)
      end

      scenario 'should raise error if book is no longer available' do
        book.update(available_count: 0)
        expect(book.reload.available_count).to eq 0

        expect { create(:loan, book: book) }.to raise_error "This book is no longer available"
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
end
