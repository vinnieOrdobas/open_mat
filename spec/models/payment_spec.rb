# frozen_string_literal: true

RSpec.describe Payment, type: :model do
  describe 'associations' do
    it { should belong_to(:order) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:amount_cents) }
    it { should validate_numericality_of(:amount_cents).is_greater_than(0) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:processor) }
    it { should validate_presence_of(:processor_id) }

    it { should define_enum_for(:status).with_values(pending: 'pending', succeeded: 'succeeded', failed: 'failed').backed_by_column_of_type(:string) }
  end
end
