# frozen_string_literal: true

RSpec.describe Academies::UpdateAcademy do
  describe '#perform' do
    let!(:owner) { create(:user, :owner) }
    let!(:academy) { create(:academy, user: owner, name: 'Old Academy Name') }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          name: 'New Academy Name',
          city: 'New City'
        }
      end
      let(:service) { described_class.new(academy, valid_params) }

      it 'updates the academy attributes' do
        service.perform
        academy.reload

        expect(academy.name).to eq('New Academy Name')
        expect(academy.city).to eq('New City')
      end

      it 'returns a success result with the updated academy' do
        result = service.perform

        expect(result[:success]).to be(true)
        expect(result[:academy]).to eq(academy)
        expect(result[:academy].name).to eq('New Academy Name')
        expect(result[:errors]).to be_nil
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          name: nil,
          city: 'Invalid City'
        }
      end
      let(:service) { described_class.new(academy, invalid_params) }

      it 'does not update the academy attributes' do
        service.perform

        academy.reload

        expect(academy.name).to eq('Old Academy Name')
        expect(academy.city).not_to eq('Invalid City')
      end

      it 'returns a failure result with errors' do
        result = service.perform

        expect(result[:success]).to be(false)
        expect(result[:academy]).to be_nil
        expect(result[:errors]).to be_an(Array)
        expect(result[:errors]).to include("Name can't be blank")
      end
    end
  end
end
