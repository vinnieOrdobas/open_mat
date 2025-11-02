# frozen_string_literal: true

RSpec.describe StudentPass, type: :model do
  let!(:user) { create(:user) }
  let(:owner) { create(:user, :owner) }
  let!(:academy) { create(:academy, user: owner) }
  let!(:order) { create(:order, user: user) }
  let!(:pass) { create(:pass, academy: academy) }
  let!(:order_line_item) { create(:order_line_item, order: order, pass: pass) }

  subject(:student_pass) do
    build(:student_pass,
          user: user,
          academy: academy,
          pass: pass,
          order_line_item: order_line_item)
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:pass) }
    it { should belong_to(:order_line_item) }
    it { should belong_to(:academy) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(active: 'active', expired: 'expired', depleted: 'depleted').backed_by_column_of_type(:string) }
  end

  describe 'validations' do
    it { should be_valid }

    it 'is invalid if both time and credit-based' do
      student_pass.expires_at = Time.current + 7.days
      student_pass.credits_remaining = 10
      expect(student_pass).not_to be_valid
      expect(student_pass.errors[:base]).to include("Pass cannot be both time-based and credit-based")
    end

    it 'is valid if only time-based' do
      student_pass.expires_at = Time.current + 7.days
      student_pass.credits_remaining = nil
      expect(student_pass).to be_valid
    end

    it 'is valid if only credit-based' do
      student_pass.expires_at = nil
      student_pass.credits_remaining = 10
      expect(student_pass).to be_valid
    end
  end
end
