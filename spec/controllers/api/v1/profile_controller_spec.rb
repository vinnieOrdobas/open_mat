# frozen_string_literal: true

RSpec.describe Api::V1::ProfileController, type: :controller do
  let!(:user) { create(:user, firstname: 'Original', lastname: 'Name', belt_rank: 'white') }
  let(:headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: user.id)}", 'Content-Type' => 'application/json' } }
  let(:json_response) { JSON.parse(response.body).deep_symbolize_keys rescue {} }

  describe 'GET #show' do
    subject(:do_action) { get :show }

    context 'with a valid token' do
      let(:expected_json) { UserSerializer.new(user).as_json.to_json }

      before { request.headers.merge!(headers) }

      it 'returns an :ok (200) status' do
        do_action
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct user data' do
        do_action
        expect(response.body).to eq(expected_json)
        expect(json_response[:id]).to eq(user.id)
      end
    end

    context 'with an invalid/missing token' do
      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH #update' do
    subject(:do_action) { patch :update, params: request_params }

    let(:valid_update_params) do
      {
        user: {
          firstname: 'Updated',
          lastname: 'Name',
          belt_rank: 'blue'
        }
      }
    end
    let(:request_params) { valid_update_params }

    context 'when authenticated' do
      before { request.headers.merge!(headers) }

      context 'with valid parameters' do
        it 'returns an :ok (200) status' do
          do_action
          expect(response).to have_http_status(:ok)
        end

        it 'updates the user in the database' do
          do_action

          user.reload
          expect(user.firstname).to eq('Updated')
          expect(user.belt_rank).to eq('blue')
        end

        it 'returns the updated user JSON' do
          do_action

          expect(json_response[:firstname]).to eq('Updated')
          expect(json_response[:belt_rank]).to eq('blue')
        end
      end

      context 'with invalid parameters' do
        let(:invalid_update_params) { { user: { firstname: '' } } }
        let(:request_params) { invalid_update_params }

        it 'returns an :unprocessable_entity (422) status' do
          do_action
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update the user in the database' do
          do_action
          expect(user.reload.firstname).to eq('Original')
        end

        it 'returns the validation errors' do
          do_action
          expect(json_response[:errors]).to include("Firstname can't be blank")
        end
      end

      context 'when attempting to update a protected attribute (e.g., role)' do
        let(:malicious_params) do
          {
            user: {
              firstname: 'Tricky',
              role: 'admin'
            }
          }
        end
        let(:request_params) { malicious_params }

        it 'does NOT update the protected attribute' do
          do_action
          expect(user.reload.role).to eq('student')
          expect(user.firstname).to eq('Tricky')
        end

        it 'returns an :ok (200) status (as the update was partially successful)' do
          do_action
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when not authenticated' do
      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
