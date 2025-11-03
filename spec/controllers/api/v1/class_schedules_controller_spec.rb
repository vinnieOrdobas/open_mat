# frozen_string_literal: true

RSpec.describe Api::V1::ClassSchedulesController, type: :controller do
  let!(:owner) { create(:user, :owner) }
  let!(:other_owner) { create(:user, :owner) }
  let!(:student) { create(:user, role: 'student') }

  let!(:academy) { create(:academy, user: owner) }

  let(:owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: owner.id)}" } }
  let(:other_owner_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: other_owner.id)}" } }
  let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student.id)}" } }

  let(:json_response) { JSON.parse(response.body).deep_symbolize_keys rescue {} }

  # === POST #create ===
  describe 'POST #create' do
    subject(:do_action) { post :create, params: request_params }

    let(:valid_params) do
      { title: 'Advanced Gi', day_of_week: '3', start_time: '19:00', end_time: '21:00' }
    end
    let(:request_params) { { academy_id: academy.id, class_schedule: valid_params } }
    let(:permitted_params) { ActionController::Parameters.new(valid_params).permit! }

    let(:mock_create_service) { instance_double(ClassSchedules::CreateSchedule) }
    let(:real_schedule) { build_stubbed(:class_schedule, academy: academy, **valid_params) }

    context 'when authenticated as the academy owner' do
      let(:expected_json) { ClassScheduleSerializer.new(real_schedule).as_json.to_json }

      before do
        request.headers.merge!(owner_headers)
        allow(ClassSchedules::CreateSchedule).to receive(:new).with(academy: academy, params: permitted_params).and_return(mock_create_service)
      end

      context 'and the service succeeds' do
        before do
          allow(mock_create_service).to receive(:perform).and_return({ success: true, schedule: real_schedule })
        end

        it 'calls the CreateSchedule service' do
          do_action
          expect(ClassSchedules::CreateSchedule).to have_received(:new).with(academy: academy, params: permitted_params)
          expect(mock_create_service).to have_received(:perform)
        end

        it 'returns a :created (201) status and the new schedule JSON' do
          do_action
          expect(response).to have_http_status(:created)
          expect(response.body).to eq(expected_json)
        end
      end

      context 'and the service fails (validation error)' do
        let(:errors) { [ "End time must be after start time" ] }

        before do
          allow(mock_create_service).to receive(:perform).and_return({ success: false, errors: errors })
        end

        it 'returns an :unprocessable_entity (422) status and the errors' do
          do_action
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response[:errors]).to match(errors)
        end
      end
    end

    context 'when authenticated as a different owner' do
      before { request.headers.merge!(other_owner_headers) }

      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Not Authorized')
      end
    end

    context 'when authenticated as a student' do
      before { request.headers.merge!(student_headers) }

      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the academy does not exist' do
      let(:request_params) { { academy_id: 'invalid-id', class_schedule: valid_params } }

      before { request.headers.merge!(owner_headers) }

      it 'returns a :not_found (404) status' do
        do_action
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # === DELETE #destroy ===
  describe 'DELETE #destroy' do
    let!(:class_schedule) { create(:class_schedule, academy: academy) }
    subject(:do_action) { delete :destroy, params: { academy_id: academy.id, id: class_schedule.id } }

    context 'when authenticated as the academy owner' do
      before { request.headers.merge!(owner_headers) }

      it 'destroys the ClassSchedule' do
        expect { do_action }.to change(ClassSchedule, :count).by(-1)
      end

      it 'returns a :no_content (204) status' do
        do_action
        expect(response).to have_http_status(:no_content)
      end

      context 'when destroy fails (e.g., callback halts)' do
        before do
          allow_any_instance_of(ClassSchedule).to receive(:destroy).and_return(false)
          allow_any_instance_of(ClassSchedule).to receive_message_chain(:errors, :full_messages).and_return([ "Cannot delete schedule" ])
        end

        it 'does not destroy the schedule' do
          expect { do_action }.not_to change(ClassSchedule, :count)
        end

        it 'returns an :unprocessable_entity (422) status' do
          do_action
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response[:errors]).to include("Cannot delete schedule")
        end
      end
    end

    context 'when authenticated as a different owner' do
      before { request.headers.merge!(other_owner_headers) }

      it 'does not destroy the schedule' do
        expect { do_action }.not_to change(ClassSchedule, :count)
      end

      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the schedule does not exist' do
      before { request.headers.merge!(owner_headers) }

      it 'returns a :not_found (404) status' do
        delete :destroy, params: { academy_id: academy.id, id: 'invalid-id' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
