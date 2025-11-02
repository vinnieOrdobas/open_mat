# frozen_string_literal: true

RSpec.describe Passes::ActivatePasses do
  before { Timecop.freeze(Time.current) }
  after { Timecop.return }

  def perform(pass)
    order = create(:order, status: 'completed')
    line_item = create(:order_line_item, order: order, pass: pass)
    described_class.new(line_item: line_item).perform
  end

  context 'with time-based passes' do
    let!(:pass) { create(:pass, :day_pass) }

    it 'correctly creates a day_pass' do
      result = perform(pass)

      expect(result[:success]).to be(true)
      student_pass = result[:student_pass]
      expect(student_pass).to be_a(StudentPass)
      expect(student_pass.status).to eq('active')
      expect(student_pass.expires_at).to be_within(1.second).of(Time.current + 1.day)
      expect(student_pass.credits_remaining).to be_nil
    end

    it 'correctly creates a week_pass' do
      pass.update!(pass_type: 'week_pass')
      result = perform(pass)

      expect(result[:success]).to be(true)
      expect(result[:student_pass].expires_at).to be_within(1.second).of(Time.current + 1.week)
      expect(result[:student_pass].credits_remaining).to be_nil
    end

    it 'correctly creates a month_pass' do
      pass.update!(pass_type: 'month_pass')
      result = perform(pass)

      expect(result[:success]).to be(true)
      expect(result[:student_pass].expires_at).to be_within(1.second).of(Time.current + 1.month)
      expect(result[:student_pass].credits_remaining).to be_nil
    end
  end

  context 'with credit-based passes' do
    let(:pass) { create(:pass, :punch_card, class_credits: 10) }

    it 'correctly creates a punch_card pass' do
      result = perform(pass)

      expect(result[:success]).to be(true)
      student_pass = result[:student_pass]
      expect(student_pass.status).to eq('active')
      expect(student_pass.credits_remaining).to eq(10)
      expect(student_pass.expires_at).to be_nil
    end

    it 'correctly creates a single pass' do
      pass.update!(pass_type: 'single')
      result = perform(pass)

      expect(result[:success]).to be(true)
      expect(result[:student_pass].credits_remaining).to eq(1)
      expect(result[:student_pass].expires_at).to be_nil
    end
  end

  context 'when StudentPass fails to save' do
    let(:pass) { create(:pass, :day_pass) }
    let(:order) { create(:order, status: 'completed') }
    let(:line_item) { create(:order_line_item, order: order, pass: pass) }
    let(:invalid_pass) { StudentPass.new } # Create the mock object

    before do
      invalid_pass.errors.add(:user, "must exist")
      allow(StudentPass).to receive(:new).and_return(invalid_pass)
      allow(invalid_pass).to receive(:expires_at=)
      allow(invalid_pass).to receive(:save).and_return(false)
    end

    it 'returns a failure result' do
      result = described_class.new(line_item: line_item).perform

      expect(result[:success]).to be(false)
      expect(result[:errors]).not_to be_empty
      expect(result[:errors]).to include("User must exist")
    end
  end
end
