require 'rails_helper'

RSpec.describe Loan, type: :model do
  it { should belong_to :user }
  it { should belong_to(:book).counter_cache(true) }

  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:borrow_at) }

  feature 'scope' do
    feature '.active' do
      let!(:active_loan) { create(:loan) }
      let!(:returned_loan) { create(:loan, :returned) }

      scenario 'should return only loans that have not been returned' do
        expect(Loan.active.count).to eq 1
        expect(Loan.active.first.id).to eq active_loan.id
      end
    end
  end
end
