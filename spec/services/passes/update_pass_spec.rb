# frozen_string_literal: true

RSpec.describe Passes::UpdatePass do
  describe '#perform' do
    let!(:owner) { create(:user, :owner) }
    let!(:academy) { create(:academy, user: owner) }
    let!(:pass) { create(:pass, academy: academy, name: 'Old Pass Name', price_cents: 1000) }

    context 'with valid parameters' do
      let(:valid_params) { { name: 'New Pass Name', price_cents: 1500 } }
      let(:service) { described_class.new(pass, valid_params) }

      it 'updates the pass attributes' do
        service.perform
        pass.reload
        expect(pass.name).to eq('New Pass Name')
        expect(pass.price_cents).to eq(1500)
      end

      it 'returns a success result with the updated pass' do
        result = service.perform
        expect(result[:success]).to be(true)
        expect(result[:pass]).to eq(pass)
        expect(result[:pass].name).to eq('New Pass Name')
        expect(result[:errors]).to be_nil
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { name: nil, price_cents: -100 } } # Invalid name and price
      let(:service) { described_class.new(pass, invalid_params) }

      it 'does not update the pass attributes' do
        service.perform
        pass.reload
        expect(pass.name).to eq('Old Pass Name')
        expect(pass.price_cents).to eq(1000)
      end

      it 'returns a failure result with errors' do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:pass]).to be_nil
        expect(result[:errors]).to include("Name can't be blank")
        expect(result[:errors]).to include("Price cents must be greater than or equal to 0")
      end
    end
  end
end
