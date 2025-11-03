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

  describe 'GET #index' do
    subject(:do_action) { get :index, params: { academy_id: academy.id } }

    let!(:schedule_tuesday) { create(:class_schedule, academy: academy, day_of_week: 2, start_time: '18:00') }
    let!(:schedule_monday_pm) { create(:class_schedule, academy: academy, day_of_week: 1, start_time: '19:00') }
    let!(:schedule_monday_am) { create(:class_schedule, academy: academy, day_of_week: 1, start_time: '10:00') }

    let!(:other_academy_schedule) { create(:class_schedule, academy: create(:academy, user: other_owner)) }

    context 'when the academy exists' do
      it 'returns an :ok (200) status' do
        do_action
        expect(response).to have_http_status(:ok)
      end

      it 'is publicly accessible (does not require authentication)' do
        do_action
        expect(response).to have_http_status(:ok)
      end

      it 'returns only the schedules for the specified academy' do
        do_action
        parsed_response = JSON.parse(response.body).map { |o| o.deep_symbolize_keys }
        expect(parsed_response).to be_an(Array)
        expect(parsed_response.count).to eq(3)
        schedule_ids = parsed_response.map { |s| s[:id] }
        expect(schedule_ids).to contain_exactly(schedule_tuesday.id, schedule_monday_pm.id, schedule_monday_am.id)
      end

      it 'returns the schedules sorted by day_of_week, then start_time' do
        do_action
        parsed_response = JSON.parse(response.body).map { |o| o.deep_symbolize_keys }

        expect(parsed_response.first[:id]).to eq(schedule_monday_am.id)
        expect(parsed_response.second[:id]).to eq(schedule_monday_pm.id)
        expect(parsed_response.last[:id]).to eq(schedule_tuesday.id)
      end
    end

    context 'when the academy does not exist' do
      subject(:do_action) { get :index, params: { academy_id: 'non-existent-id' } }

      it 'returns a :not_found (404) status' do
        do_action
        expect(response).to have_http_status(:not_found)
        expect(json_response[:error]).to eq('Academy not found')
      end
    end
  end

  describe 'POST #create' do
    subject(:do_action) { post :create, params: request_params }

    let(:valid_params) { { title: 'Advanced Gi', day_of_week: '3', start_time: '19:00', end_time: '21:00' } }
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
        before { allow(mock_create_service).to receive(:perform).and_return({ success: true, schedule: real_schedule }) }

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

        before { allow(mock_create_service).to receive(:perform).and_return({ success: false, errors: errors }) }

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

  describe 'DELETE #destroy' do
    subject(:do_action) { delete :destroy, params: { academy_id: academy.id, id: class_schedule.id } }

    let!(:class_schedule) { create(:class_schedule, academy: academy) }

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
