# frozen_string_literal: true

RSpec.describe 'Api::V1::Academy Management Workflow', type: :request do
  let!(:owner) { create(:user, :owner) }
  let!(:other_owner) { create(:user, :owner) }
  let!(:student) { create(:user) }

  let!(:amenity1) { create(:amenity, name: 'Showers') }
  let!(:amenity2) { create(:amenity, name: 'Gi Rentals') }

  let(:owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: owner.id)}", 'Content-Type' => 'application/json' } }
  let(:other_owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: other_owner.id)}", 'Content-Type' => 'application/json' } }
  let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student.id)}", 'Content-Type' => 'application/json' } } # Added
  let(:no_auth_headers) { { 'Content-Type' => 'application/json' } }

  let(:json_response) { JSON.parse(response.body).deep_symbolize_keys rescue {} }

  describe 'POST /api/v1/academies' do
    let(:valid_params) { { academy: { name: 'E2E Academy', email: 'e2e@academy.com', street_address: '1 Test St', city: 'Testville', country: 'TS' } } }

    context 'when authenticated as an owner' do
      it 'creates the academy' do
        post '/api/v1/academies', headers: owner_headers, params: valid_params.to_json
        expect(response).to have_http_status(:created)
        expect(json_response[:name]).to eq('E2E Academy')
        expect(Academy.last.user).to eq(owner)
      end
    end

    context 'when authenticated as a student' do
      it 'returns unauthorized' do
        post '/api/v1/academies', headers: student_headers, params: valid_params.to_json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        post '/api/v1/academies', headers: no_auth_headers, params: valid_params.to_json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/academies/:id' do
    let!(:academy) { create(:academy, user: owner) }

    context 'when authenticated as the owner' do
      it 'returns the academy details' do
        get "/api/v1/academies/#{academy.id}", headers: owner_headers
        expect(response).to have_http_status(:ok)
        expect(json_response[:id]).to eq(academy.id)
      end
    end

    context 'when authenticated as a different owner' do
      it 'returns unauthorized' do
        get "/api/v1/academies/#{academy.id}", headers: other_owner_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        get "/api/v1/academies/#{academy.id}", headers: no_auth_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/academies/:id' do
    let!(:academy) { create(:academy, user: owner) }
    let(:update_params) { { academy: { name: 'Updated Academy Name', city: 'New City' } } }

    context 'when authenticated as the owner' do
      it 'updates the academy' do
        patch "/api/v1/academies/#{academy.id}", headers: owner_headers, params: update_params.to_json
        expect(response).to have_http_status(:ok)
        expect(json_response[:name]).to eq('Updated Academy Name')
        expect(academy.reload.city).to eq('New City')
      end
    end

    context 'when authenticated as a different owner' do
      it 'returns unauthorized' do
        patch "/api/v1/academies/#{academy.id}", headers: other_owner_headers, params: update_params.to_json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        patch "/api/v1/academies/#{academy.id}", headers: no_auth_headers, params: update_params.to_json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/academies/:academy_id/amenities' do
    let!(:academy) { create(:academy, user: owner) }
    let(:params) { { academy_amenity: { amenity_id: amenity1.id } }.to_json }

    context 'when authenticated as the owner' do
      it 'adds the amenity to the academy' do
        post "/api/v1/academies/#{academy.id}/amenities", headers: owner_headers, params: params
        expect(response).to have_http_status(:created)
        expect(academy.amenities.reload).to include(amenity1)
      end
    end

    context 'when authenticated as a different owner' do
      it 'returns unauthorized' do
        post "/api/v1/academies/#{academy.id}/amenities", headers: other_owner_headers, params: params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/academies/:academy_id/amenities/:id' do
    let!(:academy) { create(:academy, user: owner) }
    let!(:academy_amenity) { create(:academy_amenity, academy: academy, amenity: amenity1) }

    context 'when authenticated as the owner' do
      it 'removes the amenity from the academy' do
        delete "/api/v1/academies/#{academy.id}/amenities/#{academy_amenity.id}", headers: owner_headers
        expect(response).to have_http_status(:no_content)
        expect(academy.amenities.reload).not_to include(amenity1)
      end
    end

    context 'when authenticated as a different owner' do
      it 'returns unauthorized' do
        delete "/api/v1/academies/#{academy.id}/amenities/#{academy_amenity.id}", headers: other_owner_headers
        expect(response).to have_http_status(:unauthorized)
        expect(AcademyAmenity.exists?(academy_amenity.id)).to be true
      end
    end
  end

  describe 'POST /api/v1/academies/:academy_id/passes' do
    let!(:academy) { create(:academy, user: owner) }
    let(:params) { { pass: { name: 'E2E Day Pass', pass_type: 'day_pass', price_cents: 3000 } }.to_json }

    context 'when authenticated as the owner' do
      it 'creates a pass for the academy' do
        post "/api/v1/academies/#{academy.id}/passes", headers: owner_headers, params: params
        expect(response).to have_http_status(:created)
        expect(json_response[:name]).to eq('E2E Day Pass')
        expect(academy.passes.count).to eq(1)
      end
    end

    context 'when authenticated as a different owner' do
      it 'returns unauthorized' do
        post "/api/v1/academies/#{academy.id}/passes", headers: other_owner_headers, params: params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/academies/:academy_id/passes/:id' do
    let!(:academy) { create(:academy, user: owner) }
    let!(:pass) { create(:pass, academy: academy) }
    let(:params) { { pass: { name: 'Updated Pass Name' } }.to_json }

    context 'when authenticated as the owner' do
      it 'updates the pass' do
        patch "/api/v1/academies/#{academy.id}/passes/#{pass.id}", headers: owner_headers, params: params
        expect(response).to have_http_status(:ok)
        expect(json_response[:name]).to eq('Updated Pass Name')
      end
    end

    context 'when authenticated as a different owner' do
      it 'returns unauthorized' do
        patch "/api/v1/academies/#{academy.id}/passes/#{pass.id}", headers: other_owner_headers, params: params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/academies/:academy_id/passes/:id' do
    let!(:academy) { create(:academy, user: owner) }
    let!(:pass) { create(:pass, academy: academy) }

    context 'when authenticated as the owner' do
      it 'deletes the pass' do
        delete "/api/v1/academies/#{academy.id}/passes/#{pass.id}", headers: owner_headers
        expect(response).to have_http_status(:no_content)
        expect(Pass.exists?(pass.id)).to be false
      end
    end

    context 'when authenticated as a different owner' do
      it 'returns unauthorized' do
        delete "/api/v1/academies/#{academy.id}/passes/#{pass.id}", headers: other_owner_headers
        expect(response).to have_http_status(:unauthorized)
        expect(Pass.exists?(pass.id)).to be true
      end
    end
  end
end
