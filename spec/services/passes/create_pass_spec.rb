# frozen_string_literal: true

RSpec.describe Passes::CreatePass do
  describe '#perform' do
    let!(:owner) { create(:user, :owner) }
    let!(:academy) { create(:academy, user: owner) } # Creates owner implicitly

    context 'with valid parameters' do
      let(:valid_params) do
        {
          name: '10 Class Punch Card',
          pass_type: 'punch_card',
          class_credits: 10,
          price_cents: 20000
        }
      end
      let(:service) { described_class.new(academy, valid_params) }

      it 'creates a new pass' do
        expect { service.perform }.to change(Pass, :count).by(1)
      end

      it 'returns a success result with the new pass' do
        result = service.perform
        expect(result[:success]).to be(true)
        expect(result[:pass]).to be_a(Pass)
        expect(result[:pass].name).to eq('10 Class Punch Card')
        expect(result[:errors]).to be_nil
      end

      it 'assigns the pass to the correct academy' do
        result = service.perform
        expect(result[:pass].academy).to eq(academy)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { name: nil, pass_type: 'single' } }
      let(:service) { described_class.new(academy, invalid_params) }

      it 'does not create a new pass' do
        expect { service.perform }.not_to change(Pass, :count)
      end

      it 'returns a failure result with errors' do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:pass]).to be_nil
        expect(result[:errors]).to include("Name can't be blank")
      end
    end
  end
end
