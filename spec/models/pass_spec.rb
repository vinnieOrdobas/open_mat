# frozen_string_literal: true

RSpec.describe Pass, type: :model do
  describe 'associations' do
    it { should belong_to(:academy) }
    it { should have_many(:order_line_items) }
    it { should have_many(:orders).through(:order_line_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:pass_type) }
    it { should validate_presence_of(:price_cents) }
    it { should validate_numericality_of(:price_cents).is_greater_than_or_equal_to(0) }

    it { should define_enum_for(:pass_type).with_values(single: 'single', day_pass: 'day_pass', week_pass: 'week_pass', month_pass: 'month_pass', punch_card: 'punch_card').backed_by_column_of_type(:string) }

    # Conditional validation for punch_card
    context 'when pass_type is a punch_card' do
      subject { Pass.new(pass_type: 'punch_card') }

      it { should validate_presence_of(:class_credits) }
      it { should validate_numericality_of(:class_credits).only_integer.is_greater_than(0) }
    end

    context 'when pass_type is not a punch_card' do
      subject { Pass.new(pass_type: 'day_pass') }

      it { should_not validate_presence_of(:class_credits) }
    end
  end

  describe '#punch_card?' do
    it 'returns true when pass_type is punch_card' do
      pass = Pass.new(pass_type: 'punch_card')
      expect(pass.punch_card?).to be(true)
    end

    it 'returns false when pass_type is not punch_card' do
      pass = Pass.new(pass_type: 'day_pass')
      expect(pass.punch_card?).to be(false)
    end
  end
end
