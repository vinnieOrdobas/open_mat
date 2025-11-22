# frozen_string_literal: true

RSpec.describe 'Api::V1::Academies', type: :request do
  describe 'GET /api/v1/academies (Index)' do
    let!(:owner) { create(:user, :owner) }

    let!(:amenity_showers) { create(:amenity, name: 'Showers') }
    let!(:amenity_mats) { create(:amenity, name: 'Large Mat Area') }

    let!(:academy1) { create(:academy, name: 'Academy One', city: 'Dublin', country: 'IE', user: owner) }
    let!(:pass1) { create(:pass, :day_pass, academy: academy1) }
    let!(:schedule1) { create(:class_schedule, academy: academy1, day_of_week: 1) } # Monday
    let!(:link1) { create(:academy_amenity, academy: academy1, amenity: amenity_showers) }

    let!(:academy2) { create(:academy, name: 'Academy Two', city: 'Dublin', country: 'IE', user: owner) }

    let!(:academy3) { create(:academy, name: 'Academy Three', city: 'Cork', country: 'IE', user: owner) }
    let!(:pass3) { create(:pass, :month_pass, academy: academy3) }
    let!(:link3) { create(:academy_amenity, academy: academy3, amenity: amenity_showers) }

    let!(:academy4) { create(:academy, name: 'Academy Four', city: 'London', country: 'GB', user: owner) }
    let!(:schedule4) { create(:class_schedule, academy: academy4, day_of_week: 2) } # Tuesday
    let!(:link4) { create(:academy_amenity, academy: academy4, amenity: amenity_mats) }

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

    context 'when searching by "term" (Smart Search)' do
      it 'filters by city (e.g., Dublin)' do
        get '/api/v1/academies?term=Dublin'
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(2)
        expect(json_response.map { |a| a['name'] }).to contain_exactly('Academy One', 'Academy Two')
      end

      it 'filters by country (e.g., IE)' do
        get '/api/v1/academies?term=IE'
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(3)
      end

      it 'filters by name (e.g., Four)' do
        get '/api/v1/academies?term=Four'
        expect(response).to have_http_status(:ok)
        expect(json_response.count).to eq(1)
        expect(json_response.first['name']).to eq('Academy Four')
      end
    end

    # --- 3. Advanced Filters ---
    context 'when using advanced filters' do
      it 'filters by pass type (e.g. day_pass)' do
        get '/api/v1/academies?pass_types=day_pass'
        expect(json_response.count).to eq(1)
        expect(json_response.first['id']).to eq(academy1.id)
      end

      it 'filters by class day (e.g. Monday=1)' do
        get '/api/v1/academies?class_days=1'
        expect(json_response.count).to eq(1)
        expect(json_response.first['id']).to eq(academy1.id)
      end

      it 'filters by amenity' do
        get "/api/v1/academies?amenity_ids=#{amenity_mats.id},#{amenity_showers.id}"
        expect(json_response.count).to eq(1)
        expect(json_response.first['id']).to eq(academy4.id)
      end
    end

    context 'when chaining filters' do
      it 'filters by Term AND Pass Type' do
        get '/api/v1/academies?term=Dublin&pass_types=day_pass'
        expect(json_response.count).to eq(1)
        expect(json_response.first['id']).to eq(academy1.id)

        get '/api/v1/academies?term=London&pass_types=day_pass'
        expect(JSON.parse(response.body)).to be_empty
      end
    end
  end

  describe 'GET /api/v1/academies/:id (Show)' do
    let!(:owner) { create(:user, :owner) }
    let!(:academy) { create(:academy, user: owner, name: 'Detailed Academy') }
    let!(:amenity) { create(:amenity, name: 'Mats') }
    let!(:pass) { create(:pass, academy: academy, name: 'Single Class') }

    before do
      create(:academy_amenity, academy: academy, amenity: amenity)
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
