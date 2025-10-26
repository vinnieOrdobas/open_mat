# frozen_string_literal: true

RSpec.describe 'Api::V1::Authentication', type: :request do
  let(:json_response) { JSON.parse(response.body).deep_symbolize_keys }

  # --- Test Group 1: Registration ---
  describe 'POST /api/v1/users (Registration)' do
    let(:valid_params) do
      {
        user: {
          firstname: 'E2E',
          lastname: 'Test',
          email: 'e2e@example.com',
          username: 'e2e_user',
          password: 'password123',
          password_confirmation: 'password123'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post '/api/v1/users', params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'returns a :created (201) status and the user object' do
        post '/api/v1/users', params: valid_params

        expect(response).to have_http_status(:created)
        expect(json_response[:username]).to eq('e2e_user')
        expect(json_response[:email]).to eq('e2e@example.com')
      end
    end

    context 'with invalid parameters' do
      it 'returns an :unprocessable_entity (422) status' do
        invalid_params = valid_params.merge(user: { email: nil })
        post '/api/v1/users', params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(User.count).to eq(0)
      end
    end
  end

  # --- Test Group 2: Login ---
  describe 'POST /api/v1/login (Login)' do
    let!(:user) do
      User.create!(
        firstname: 'E2E',
        lastname: 'Test',
        email: 'e2e@example.com',
        username: 'e2e_user',
        password: 'password123'
      )
    end

    context 'with valid credentials' do
      let(:valid_login_params) do
        { session: { email: 'e2e@example.com', password: 'password123' } }
      end

      it 'returns an :ok (200) status and a token' do
        post '/api/v1/login', params: valid_login_params

        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key(:token)
        expect(json_response).to have_key(:exp)
      end
    end

    context 'with invalid credentials' do
      let(:invalid_login_params) do
        { session: { email: 'e2e@example.com', password: 'wrong' } }
      end

      it 'returns an :unauthorized (401) status' do
        post '/api/v1/login', params: invalid_login_params

        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Invalid email or password')
      end
    end
  end

  # --- Test Group 3: Protected Endpoint ---
  describe 'GET /api/v1/profile (Protected Route)' do
    let!(:user) do
      User.create!(
        firstname: 'E2E',
        lastname: 'Test',
        email: 'e2e@example.com',
        username: 'e2e_user',
        password: 'password123'
      )
    end

    context 'with a valid token' do
      let(:token) { JsonWebToken.encode(user_id: user.id) }
      let(:headers) { { 'Authorization' => "Bearer #{token}" } }

      it 'returns the user profile' do
        get '/api/v1/profile', headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response[:id]).to eq(user.id)
        expect(json_response[:email]).to eq('e2e@example.com')
      end
    end

    context 'with an expired token' do
      let(:token) { JsonWebToken.encode({ user_id: user.id }, 1.hour.ago) }
      let(:headers) { { 'Authorization' => "Bearer #{token}" } }

      it 'returns an :unauthorized (401) status' do
        Timecop.freeze(Time.current) do
          get '/api/v1/profile', headers: headers
        end

        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Not Authorized')
      end
    end

    context 'with no token' do
      it 'returns an :unauthorized (401) status' do
        get '/api/v1/profile'

        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Not Authorized')
      end
    end
  end
end
