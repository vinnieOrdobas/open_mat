# frozen_string_literal: true

RSpec.describe Api::V1::SessionsController, type: :controller do
  describe 'POST #create' do
    let(:email) { 'test@example.com' }
    let(:password) { 'password123' }
    let(:request_params) { { session: { email: email, password: password } } }
    let(:mock_auth_service) { instance_double(Sessions::AuthenticateUser) }
    let(:mock_user) { instance_double(User, id: 1) }
    let(:mock_token) { 'fake.jwt.token' }

    let(:do_action) { post :create, params: request_params }

    before do
      allow(Sessions::AuthenticateUser).to receive(:new).with(email, password).and_return(mock_auth_service)
      allow(JsonWebToken).to receive(:encode).with(user_id: mock_user.id).and_return(mock_token)
    end

    context 'with valid credentials' do
      let(:expected_hash) { { token: mock_token, exp: an_instance_of(Integer) } }

      before { allow(mock_auth_service).to receive(:authenticate).and_return(mock_user) }

      it 'calls the AuthenticateUser service' do
        do_action
        expect(Sessions::AuthenticateUser).to have_received(:new).with(email, password)
        expect(mock_auth_service).to have_received(:authenticate)
      end

      it 'calls the JsonWebToken module to encode a token' do
        do_action
        expect(JsonWebToken).to have_received(:encode).with(user_id: mock_user.id)
      end

      it 'returns an :ok (200) status and the token' do
        do_action

        result_hash = JSON.parse(response.body).deep_symbolize_keys

        expect(response).to have_http_status(:ok)
        expect(result_hash).to match(expected_hash)
        expect(result_hash[:token]).to eq(mock_token)
      end
    end

    context 'with invalid credentials' do
      let(:expected_hash) { { error: 'Invalid email or password' } }

      before { allow(mock_auth_service).to receive(:authenticate).and_return(nil) }

      it 'calls the AuthenticateUser service' do
        do_action
        expect(mock_auth_service).to have_received(:authenticate)
      end

      it 'does NOT call the JsonWebToken module' do
        do_action
        expect(JsonWebToken).not_to have_received(:encode)
      end

      it 'returns an :unauthorized (401) status and an error message' do
        do_action

        result_hash = JSON.parse(response.body).deep_symbolize_keys

        expect(response).to have_http_status(:unauthorized)
        expect(result_hash).to match(expected_hash)
      end
    end
  end
end
