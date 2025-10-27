# frozen_string_literal: true

RSpec.describe Api::V1::AcademyAmenitiesController, type: :controller do
  let!(:owner) { create(:user, :owner) }
  let!(:other_owner) { create(:user, :owner) }
  let!(:student) { create(:user, role: 'student') }

  let!(:academy) { create(:academy, user: owner) }
  let!(:amenity) { create(:amenity, name: 'Showers') }

  let(:owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: owner.id)}" } }
  let(:other_owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: other_owner.id)}" } }
  let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student.id)}" } }

  describe 'POST #create' do
    subject(:do_action) { post :create, params: request_params }

    let(:request_params) { { academy_id: academy.id, academy_amenity: { amenity_id: amenity.id } } }

    context 'when authenticated as the academy owner' do
      before { request.headers.merge!(owner_headers) }

      context 'with a valid amenity_id' do
        it 'creates a new AcademyAmenity link' do
          expect { do_action }.to change(AcademyAmenity, :count).by(1)
        end

        it 'associates the amenity with the correct academy' do
          do_action
          expect(academy.amenities.reload).to include(amenity)
        end

        it 'returns a :created (201) status and the new association id' do
          do_action
          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:created)
          expect(json_response).to have_key('id')
          expect(json_response['id']).to eq(AcademyAmenity.last.id)
        end
      end

      context 'with an invalid amenity_id' do
        let(:request_params) { { academy_id: academy.id, academy_amenity: { amenity_id: 'invalid' } } }

        it 'does not create a new AcademyAmenity link' do
          expect { do_action }.not_to change(AcademyAmenity, :count)
        end

        it 'returns a :not_found (404) status' do
          do_action
          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)['error']).to eq('Amenity not found')
        end
      end

      context 'when the amenity is already added' do
        let!(:existing_link) { create(:academy_amenity, academy: academy, amenity: amenity) }

        it 'does not create a duplicate link' do
          expect { do_action }.not_to change(AcademyAmenity, :count)
        end

        it 'returns an :unprocessable_entity (422) status with errors' do
          do_action
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['errors']).to include('Amenity has already been taken')
        end
      end
    end

    context 'when authenticated as a different owner' do
      before { request.headers.merge!(other_owner_headers) }

      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the academy does not exist' do
      let(:request_params) { { academy_id: 'invalid', academy_amenity: { amenity_id: amenity.id } } }
      before { request.headers.merge!(owner_headers) }

      it 'returns a :not_found (404) status' do
        do_action
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Academy not found')
      end
    end

    context 'with no authenticated user' do
      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    subject(:do_action) { delete :destroy, params: request_params }

    let!(:academy_amenity) { create(:academy_amenity, academy: academy, amenity: amenity) }
    let(:request_params) { { academy_id: academy.id, id: academy_amenity.id } }

    context 'when authenticated as the academy owner' do
      before { request.headers.merge!(owner_headers) }

      it 'destroys the AcademyAmenity link' do
        expect { do_action }.to change(AcademyAmenity, :count).by(-1)
      end

      it 'returns a :no_content (204) status' do
        do_action
        expect(response).to have_http_status(:no_content)
      end

      context 'when the link ID does not exist for this academy' do
        let(:request_params) { { academy_id: academy.id, id: 'invalid' } }

        it 'does not destroy anything' do
          expect { do_action }.not_to change(AcademyAmenity, :count)
        end

        it 'returns a :not_found (404) status' do
          do_action
          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)['error']).to eq('Academy amenity link not found')
        end
      end
    end

    context 'when authenticated as a different owner' do
      before { request.headers.merge!(other_owner_headers) }

      it 'does not destroy the link' do
        expect { do_action }.not_to change(AcademyAmenity, :count)
      end

      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with no authenticated user' do
      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
