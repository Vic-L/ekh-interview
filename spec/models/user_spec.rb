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
end
