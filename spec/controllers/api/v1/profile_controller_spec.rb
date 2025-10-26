RSpec.describe Api::V1::ProfileController, type: :controller do
  describe 'GET #show' do
    subject(:do_action) { get :show }

    let!(:user) do
      create(:user,
        firstname: 'Test',
        lastname: 'User',
        email: 'test@example.com',
        username: 'testuser',
        password: 'password123'
      )
    end
    let(:json_response) { JSON.parse(response.body).deep_symbolize_keys }

    context 'with a valid token' do
      let(:valid_token) { JsonWebToken.encode(user_id: user.id) }
      let(:valid_headers) { { 'Authorization' => "Bearer #{valid_token}" } }

      let(:expected_json) { UserSerializer.new(user).as_json.deep_symbolize_keys }

      before { request.headers.merge!(valid_headers) }

      it 'returns an :ok (200) status' do
        do_action
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct user data' do
        do_action

        expect(json_response).to eq(expected_json)
        expect(json_response[:id]).to eq(user.id)
        expect(json_response[:email]).to eq(user.email)
      end
    end

    context 'with an invalid token (e.g., expired)' do
      let(:expired_token) { JsonWebToken.encode({ user_id: user.id }, 1.hour.ago) }
      let(:invalid_headers) { { 'Authorization' => "Bearer #{expired_token}" } }

      before { request.headers.merge!(invalid_headers) }

      it 'returns an :unauthorized (401) status' do
        Timecop.freeze(Time.current) { do_action }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a "Not Authorized" error' do
        Timecop.freeze(Time.current) { do_action }
        expect(json_response[:error]).to eq('Not Authorized')
      end
    end

    context 'with no token' do
      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a "Not Authorized" error' do
        do_action
        expect(json_response[:error]).to eq('Not Authorized')
      end
    end
  end
end
