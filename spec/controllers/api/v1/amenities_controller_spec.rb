# frozen_string_literal: true

RSpec.describe Api::V1::AmenitiesController, type: :controller do
  describe 'GET #index' do
    subject(:do_action) { get :index }

    let!(:amenity1) { create(:amenity, name: 'Showers', category: 'facilities') }
    let!(:amenity2) { create(:amenity, name: 'Gi Rentals', category: 'equipment') }

    let(:json_response) { JSON.parse(response.body) }

    it 'returns an :ok (200) status' do
      do_action
      expect(response).to have_http_status(:ok)
    end

    it 'returns a list of all amenities' do
      do_action
      expect(json_response).to be_an(Array)
      expect(json_response.count).to eq(2)
      expect(json_response.first['name']).to eq(amenity1.name)
      expect(json_response.last['name']).to eq(amenity2.name)
    end

    it 'uses the AmenitySerializer' do
      do_action
      expect(json_response.first).to include('id', 'name', 'category', 'icon_name', 'created_at', 'updated_at')
    end
  end
end
