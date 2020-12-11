require 'rails_helper'

RSpec.describe Book, type: :model do
  it { should have_many :loans }
end
