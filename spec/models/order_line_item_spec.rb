# frozen_string_literal: true

RSpec.describe OrderLineItem, type: :model do
  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:pass) }
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).only_integer.is_greater_than(0) }

    it { should validate_presence_of(:price_at_purchase_cents) }
    it { should validate_numericality_of(:price_at_purchase_cents).is_greater_than_or_equal_to(0) }

    it { should define_enum_for(:status).with_values(
    pending_approval: 'pending_approval',
      approved: 'approved',
      rejected: 'rejected'
    ).backed_by_column_of_type(:string) }
  end
end
