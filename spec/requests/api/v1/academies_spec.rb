# frozen_string_literal: true

RSpec.describe 'Api::V1::Academies', type: :request do
  describe 'GET /api/v1/academies (Index)' do
    let!(:amenity_showers) { create(:amenity, name: 'Showers') }
    let!(:amenity_mats) { create(:amenity, name: 'Large Mat Area') } # Not used by academies

    let!(:academy1) { create(:academy, name: 'Academy One', city: 'Dublin', country: 'IE') }
    let!(:academy2) { create(:academy, name: 'Academy Two', city: 'Dublin', country: 'IE') }
    let!(:academy3) { create(:academy, name: 'Academy Three', city: 'Cork', country: 'IE') }
    let!(:academy4) { create(:academy, name: 'Academy Four', city: 'London', country: 'GB') }

    before do
      create(:academy_amenity, academy: academy1, amenity: amenity_showers)
      create(:academy_amenity, academy: academy3, amenity: amenity_showers)
    end

    let(:json_response) { JSON.parse(response.body) }

    context 'without filters' do
      before { get '/api/v1/academies' }

      it 'returns an :ok (200) status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a list of all academies' do
        expect(json_response).to be_an(Array)
        expect(json_response.count).to eq(4)
      end

      it 'returns data structured by the AcademySerializer' do
        expect(json_response.first).to include('id', 'name', 'city', 'country')
        expect(json_response.first).not_to include('payout_info')
      end
    end

    context 'when filtering by city' do
      it 'returns only academies in that city (case-insensitive)' do
        get '/api/v1/academies?city=Dublin'
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(2)
        expect(json_response.map { |a| a['name'] }).to contain_exactly('Academy One', 'Academy Two')

        get '/api/v1/academies?city=dublin'
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(2)
      end

      it 'returns academies matching partially by city' do
        get '/api/v1/academies?city=Dub'
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(2)
        expect(json_response.map { |a| a['name'] }).to contain_exactly('Academy One', 'Academy Two')
      end
    end

    context 'when filtering by country' do
      it 'returns only academies in that country (case-insensitive)' do
        get '/api/v1/academies?country=IE'
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(3)
        expect(json_response.map { |a| a['name'] }).to contain_exactly('Academy One', 'Academy Two', 'Academy Three')

        get '/api/v1/academies?country=ie'
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(3)
      end
    end

    context 'when filtering by amenity_id' do
      it 'returns only academies with that amenity' do
        get "/api/v1/academies?amenity_id=#{amenity_showers.id}"
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(2)
        expect(json_response.map { |a| a['name'] }).to contain_exactly('Academy One', 'Academy Three')
      end

      it 'returns an empty list if no academy has the amenity' do
        get "/api/v1/academies?amenity_id=#{amenity_mats.id}"
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(0)
      end
    end

    context 'when chaining multiple filters' do
      it 'returns academies matching all criteria' do
        get "/api/v1/academies?city=Dublin&country=IE&amenity_id=#{amenity_showers.id}"
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(1)
        expect(json_response.first['name']).to eq('Academy One')
      end
    end
  end

  describe 'GET /api/v1/academies/:id (Show)' do
    let!(:owner) { create(:user, :owner) }
    let!(:academy) { create(:academy, user: owner, name: 'Detailed Academy') }
    let!(:amenity) { create(:amenity, name: 'Mats') }
    let!(:pass) { create(:pass, academy: academy, name: 'Single Class') }

    before do
      academy.amenities << amenity
    end

    let(:json_response) { JSON.parse(response.body).deep_symbolize_keys }

    context 'when requesting a valid academy ID' do
      before do
        get "/api/v1/academies/#{academy.id}"
      end

      it 'returns an :ok (200) status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct academy details' do
        expect(json_response[:id]).to eq(academy.id)
        expect(json_response[:name]).to eq('Detailed Academy')
      end

      it 'includes the associated amenities' do
        expect(json_response[:amenities]).to be_an(Array)
        expect(json_response[:amenities].count).to eq(1)
        expect(json_response[:amenities].first[:name]).to eq('Mats')
      end

      it 'includes the associated passes' do
        expect(json_response[:passes]).to be_an(Array)
        expect(json_response[:passes].count).to eq(1)
        expect(json_response[:passes].first[:name]).to eq('Single Class')
      end

      it 'does NOT require authentication' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when requesting an invalid academy ID' do
      before do
        get "/api/v1/academies/invalid-id"
      end

      it 'returns a :not_found (404) status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
