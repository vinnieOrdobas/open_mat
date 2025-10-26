# frozen_string_literal: true

RSpec.describe Api::V1::UsersController, type: :controller do
    describe 'POST #create' do
      subject(:do_action) { post :create, params: request_params }

      let(:valid_user_params) do
        {
          firstname: 'Test',
          lastname: 'User',
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          password_confirmation: 'password123'
        }
      end

      let(:request_params) { { user: valid_user_params } }

      let(:permitted_params) do
        ActionController::Parameters.new(valid_user_params).permit(
          :firstname, :lastname, :email, :username, :password, :password_confirmation
        )
      end

      let(:mock_register_service) { instance_double(Users::RegisterUser) }
      let(:mock_user) { instance_double(User, id: 1) }
      let(:mock_serializer) { instance_double(UserSerializer) }

      before do
        allow(Users::RegisterUser).to receive(:new).with(permitted_params).and_return(mock_register_service)
        allow(UserSerializer).to receive(:new).with(mock_user).and_return(mock_serializer)
      end

      context 'on success' do
        let(:expected_hash) { { id: 1, username: 'testuser' } }

        before do
          allow(mock_register_service).to receive(:register).and_return(
            { success: true, user: mock_user }
          )
          allow(mock_serializer).to receive(:as_json).and_return(expected_hash.to_json)
        end

        it 'calls the service and serializer' do
          do_action

          expect(Users::RegisterUser).to have_received(:new).with(permitted_params)
          expect(mock_register_service).to have_received(:register)
          expect(UserSerializer).to have_received(:new).with(mock_user)
        end

        it 'returns a :created (201) status and the serialized user' do
          do_action

          result_hash = JSON.parse(response.body).deep_symbolize_keys

          expect(response).to have_http_status(:created)
          expect(result_hash).to match(expected_hash)
        end
      end

      context 'on failure' do
        let(:error_messages) { [ "Email can't be blank" ] }
        let(:expected_hash) { { errors: error_messages } }

        before do
          allow(mock_register_service).to receive(:register).and_return(
            { success: false, errors: error_messages }
          )
        end

        it 'calls the service but not the serializer' do
          do_action

          expect(Users::RegisterUser).to have_received(:new).with(permitted_params)
          expect(mock_register_service).to have_received(:register)
          expect(UserSerializer).not_to have_received(:new)
        end

        it 'returns an :unprocessable_entity (422) status and the errors' do
          do_action

          result_hash = JSON.parse(response.body).deep_symbolize_keys

          expect(response).to have_http_status(:unprocessable_entity)
          expect(result_hash).to match(expected_hash)
        end
      end
    end
  end
