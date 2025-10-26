# frozen_string_literal: true

RSpec.describe Api::V1::ApplicationController, type: :controller do
  controller do
    before_action :authenticate_request!

    def index
      render json: { message: 'success' }, status: :ok
    end
  end

  let!(:user) { User.create!(firstname: 'Test', lastname: 'User', email: 'test@example.com', username: 'testuser', password: 'password') }
  let(:valid_token) { JsonWebToken.encode(user_id: user.id) }
  let(:valid_headers) { { 'Authorization' => "Bearer #{valid_token}" } }

  describe '#authenticate_request!' do
    context 'with valid headers' do
      before { request.headers.merge!(valid_headers) }

      it 'allows the request to proceed' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('success')
      end
    end

    context 'with an invalid (e.g., expired) token' do
      let(:expired_token) { JsonWebToken.encode({ user_id: user.id }, 1.hour.ago) }
      let(:invalid_headers) { { 'Authorization' => "Bearer #{expired_token}" } }

      before do
        Timecop.freeze(Time.current) do
          request.headers.merge!(invalid_headers)
          get :index
        end
      end

      it 'returns an :unauthorized (401) status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a "Not Authorized" error message' do
        json_response = JSON.parse(response.body).deep_symbolize_keys
        expect(json_response[:error]).to eq('Not Authorized')
      end
    end

    context 'with missing headers (no token)' do
      before { get :index }

      it 'returns an :unauthorized (401) status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a "Not Authorized" error message' do
        json_response = JSON.parse(response.body).deep_symbolize_keys
        expect(json_response[:error]).to eq('Not Authorized')
      end
    end
  end
end
