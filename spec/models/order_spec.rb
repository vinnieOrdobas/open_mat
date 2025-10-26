# frozen_string_literal: true

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:order_line_items).dependent(:destroy) }
    it { should have_many(:passes).through(:order_line_items) }
    it { should have_one(:payment).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:total_price_cents) }
    it { should validate_numericality_of(:total_price_cents).is_greater_than_or_equal_to(0) }

    it { should define_enum_for(:status).with_values(pending: 'pending', completed: 'completed', failed: 'failed').backed_by_column_of_type(:string) }
  end
end
