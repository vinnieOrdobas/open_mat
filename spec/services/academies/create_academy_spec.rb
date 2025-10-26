# frozen_string_literal: true

RSpec.describe Academies::CreateAcademy do
  describe '#perform' do
    let!(:owner) { create(:user, :owner) }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          name: 'Atos Jiu-Jitsu',
          street_address: '123 Mat St',
          city: 'Anytown',
          country: 'USA',
          email: 'info@atosjj.com'
        }
      end
      let(:service) { described_class.new(owner, valid_params) }

      it 'creates a new academy' do
        expect { service.perform }.to change(Academy, :count).by(1)
      end

      it 'returns a success result with the new academy' do
        result = service.perform

        # Test the return value
        expect(result[:success]).to be(true)
        expect(result[:academy]).to be_an(Academy)
        expect(result[:academy].name).to eq('Atos Jiu-Jitsu')
        expect(result[:errors]).to be_nil
      end

      it 'assigns the academy to the correct owner' do
        result = service.perform

        expect(result[:academy].user).to eq(owner)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          name: nil,
          street_address: '123 Mat St',
          city: 'Anytown',
          country: 'USA'
        }
      end
      let(:service) { described_class.new(owner, invalid_params) }

      it 'does not create a new academy' do
        expect { service.perform }.not_to change(Academy, :count)
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
