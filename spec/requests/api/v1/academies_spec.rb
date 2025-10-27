# frozen_string_literal: true

RSpec.describe 'Api::V1::Academies', type: :request do
  describe 'GET /api/v1/academies (Index)' do
    let!(:academy1) { create(:academy, name: 'Academy One', city: 'City A') }
    let!(:academy2) { create(:academy, name: 'Academy Two', city: 'City B') }

    let(:json_response) { JSON.parse(response.body) }

    before do
      get '/api/v1/academies'
    end

    it 'returns an :ok (200) status' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a list of all academies' do
      expect(json_response).to be_an(Array)
      expect(json_response.count).to eq(2)

      academy_names = json_response.map { |academy| academy['name'] }
      expect(academy_names).to include('Academy One', 'Academy Two')
    end

    it 'returns academy data structured by the AcademySerializer' do
      expect(json_response.first).to include('id', 'name', 'city', 'country', 'created_at')
      expect(json_response.first).not_to include('payout_info')
    end
  end

  # We will add describe blocks for GET /show, POST /create, PATCH /update later
  # if needed for E2E testing of those specific endpoints, but the controller
  # specs and academy_management_spec cover those well for now.
end
