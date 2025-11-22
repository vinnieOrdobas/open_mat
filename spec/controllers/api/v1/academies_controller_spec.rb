# frozen_string_literal: true

RSpec.describe Api::V1::AcademiesController, type: :controller do
  let!(:owner_user) { create(:user, :owner) }
  let!(:other_owner) { create(:user, :owner) }
  let!(:student_user) { create(:user, role: 'student') }

  let(:owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: owner_user.id)}" } }
  let(:other_owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: other_owner.id)}" } }
  let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student_user.id)}" } }

  describe 'GET #index' do
    subject(:do_action) { get :index, params: request_params }
    let(:request_params) { {} }

    let(:mock_query_object) { instance_double(Academies::SearchQuery) }
    let!(:academy1) { create(:academy, name: 'Academy One') }
    let!(:academy2) { create(:academy, name: 'Academy Two') }
    let(:filtered_academies) { [ academy1, academy2 ] }

    before do
      allow(Academies::SearchQuery).to receive(:new).and_return(mock_query_object)
      allow(mock_query_object).to receive(:by_term).and_return(mock_query_object)
      allow(mock_query_object).to receive(:with_amenity_id).and_return(mock_query_object)
      allow(mock_query_object).to receive(:by_pass_type).and_return(mock_query_object)
      allow(mock_query_object).to receive(:by_class_day).and_return(mock_query_object)
      allow(mock_query_object).to receive(:results).and_return(filtered_academies)

      allow(AcademySerializer).to receive(:new).and_call_original
    end

    it 'instantiates a SearchQuery' do
      do_action
      expect(Academies::SearchQuery).to have_received(:new)
    end

    it 'calls .results on the query object' do
      do_action
      expect(mock_query_object).to have_received(:results)
    end

    it 'returns an :ok (200) status and renders a JSON array' do
      do_action
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.length).to eq(2)
    end

    context 'with term filter param' do
      let(:request_params) { { term: 'Dublin' } }

      it 'calls .by_term on the query object' do
        do_action
        expect(mock_query_object).to have_received(:by_term).with('Dublin')
      end
    end

    context 'with pass_type filter param' do
      let(:request_params) { { pass_type: 'day_pass' } }

      it 'calls .by_pass_type on the query object' do
        do_action
        expect(mock_query_object).to have_received(:by_pass_type).with('day_pass')
      end
    end

    context 'with class_day filter param' do
      let(:request_params) { { class_day: '1' } }

      it 'calls .by_class_day on the query object' do
        do_action
        expect(mock_query_object).to have_received(:by_class_day).with('1')
      end
    end

    context 'with amenity_id filter param' do
      let(:request_params) { { amenity_id: '5' } }

      it 'calls .with_amenity_id on the query object' do
        do_action
        expect(mock_query_object).to have_received(:with_amenity_id).with('5')
      end
    end

    context 'with multiple filter params' do
      let(:request_params) { { term: 'Cork', amenity_id: '10', pass_type: 'month_pass' } }

      it 'calls all relevant filter methods' do
        do_action
        expect(mock_query_object).to have_received(:by_term).with('Cork')
        expect(mock_query_object).to have_received(:with_amenity_id).with('10')
        expect(mock_query_object).to have_received(:by_pass_type).with('month_pass')
      end
    end
  end

  describe 'POST #create' do
    subject(:do_action) { post :create, params: request_params }

    let(:valid_academy_params) do
      { name: 'Gracie Barra Anytown', email: 'info@gbanytown.com', street_address: '123 Mat St', city: 'Anytown', country: 'USA' }
    end
    let(:request_params) { { academy: valid_academy_params } }
    let(:permitted_params) { ActionController::Parameters.new(valid_academy_params).permit! }

    let(:mock_create_service) { instance_double(Academies::CreateAcademy) }
    let(:mock_academy) { instance_double(Academy, id: 1) }
    let(:mock_serializer) { instance_double(AcademySerializer) }

    context 'with an authenticated owner user' do
      let(:expected_hash) { { id: 1, name: 'Gracie Barra Anytown' } }

      before do
        request.headers.merge!(owner_headers)
        allow(Academies::CreateAcademy).to receive(:new).with(owner_user, permitted_params).and_return(mock_create_service)
        allow(mock_create_service).to receive(:perform).and_return({ success: true, academy: mock_academy })
        allow(AcademySerializer).to receive(:new).with(mock_academy).and_return(mock_serializer)
        allow(mock_serializer).to receive(:as_json).and_return(expected_hash.to_json)
      end

      it 'calls the CreateAcademy service' do
        do_action
        expect(Academies::CreateAcademy).to have_received(:new).with(owner_user, permitted_params)
        expect(mock_create_service).to have_received(:perform)
      end

      it 'returns a :created (201) status' do
        do_action
        expect(response).to have_http_status(:created)
      end
    end

    context 'with an authenticated user who is NOT an owner' do
      before { request.headers.merge!(student_headers) }

      it 'does NOT call the CreateAcademy service' do
        allow(Academies::CreateAcademy).to receive(:new)
        do_action
        expect(Academies::CreateAcademy).not_to have_received(:new)
      end

      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with no authenticated user (missing token)' do
      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #show' do
    subject(:do_action) { get :show, params: { id: academy.id } }

    let!(:academy) { create(:academy, user: owner_user) }

    let(:mock_serializer) { instance_double(AcademySerializer) }
    let(:expected_hash) { { id: academy.id, name: academy.name } }

    before do
      allow(AcademySerializer).to receive(:new).with(an_instance_of(Academy)).and_return(mock_serializer)
      allow(mock_serializer).to receive(:as_json).and_return(expected_hash.to_json)
    end

    context 'when requesting a valid academy' do
      it 'returns an :ok (200) status' do
        do_action
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct academy JSON via the serializer' do
        do_action
        expect(AcademySerializer).to have_received(:new).with(an_instance_of(Academy))
        expect(response.body).to eq(expected_hash.to_json)
      end
    end

    context 'when authenticated as the academy owner' do
      before { request.headers.merge!(owner_headers) }

      it 'returns an :ok (200) status' do
        do_action
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct academy JSON' do
        do_action
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(academy.id)
        expect(json_response['name']).to eq(academy.name)
      end
    end

    context 'when the academy does not exist' do
      before { request.headers.merge!(owner_headers) }

      it 'returns a :not_found (44) status' do
        get :show, params: { id: 'invalid-id' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH #update' do
    subject(:do_action) { patch :update, params: request_params }

    let!(:academy) { create(:academy, user: owner_user, name: 'Old Name') }
    let(:update_params) { { name: 'New Name' } }
    let(:request_params) { { id: academy.id, academy: update_params } }
    let(:permitted_params) { ActionController::Parameters.new(update_params).permit! }

    let(:mock_update_service) { instance_double(Academies::UpdateAcademy) }
    let(:mock_serializer) { instance_double(AcademySerializer) }

    context 'when authenticated as the academy owner' do
      let(:expected_hash) { { id: academy.id, name: 'New Name' } }

      before do
        request.headers.merge!(owner_headers)
        allow(Academies::UpdateAcademy).to receive(:new).with(academy, permitted_params).and_return(mock_update_service)
        allow(mock_update_service).to receive(:perform).and_return({ success: true, academy: academy.tap { |a| a.name = 'New Name' } })
        allow(AcademySerializer).to receive(:new).with(an_instance_of(Academy)).and_return(mock_serializer)
        allow(mock_serializer).to receive(:as_json).and_return(expected_hash.to_json)
      end

      it 'calls the UpdateAcademy service' do
        do_action
        expect(Academies::UpdateAcademy).to have_received(:new).with(academy, permitted_params)
        expect(mock_update_service).to have_received(:perform)
      end

      it 'returns an :ok (200) status and the updated academy' do
        do_action
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(expected_hash.to_json)
      end

      context 'when the service fails (validation error)' do
        let(:errors) { [ "Name can't be blank" ] }
        before do
          allow(mock_update_service).to receive(:perform).and_return({ success: false, errors: errors })
        end

        it 'returns an :unprocessable_entity (422) status' do
          do_action
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when authenticated as a different owner' do
      before do
        request.headers.merge!(other_owner_headers)
        allow(Academies::UpdateAcademy).to receive(:new) # Stub to check
      end

      it 'does NOT call the UpdateAcademy service' do
        do_action
        expect(Academies::UpdateAcademy).not_to have_received(:new)
      end

      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
