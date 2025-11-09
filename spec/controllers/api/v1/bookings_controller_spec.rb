# frozen_string_literal: true

RSpec.describe Api::V1::BookingsController, type: :controller do
  describe 'POST #create' do
    let!(:student) { create(:user, role: 'student') }
    let(:owner) { create(:user, role: 'owner') }
    let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student.id)}" } }

    let!(:academy) { create(:academy, user: owner) }
    let!(:class_schedule) { create(:class_schedule, academy: academy) }

    let(:other_owner) { create(:user, role: 'owner') }
    let!(:other_academy) { create(:academy, user: other_owner) }
    let!(:other_schedule) { create(:class_schedule, academy: other_academy) }

    let(:request_params) { { academy_id: academy.id, class_schedule_id: class_schedule.id } }

    let(:mock_booking_service) { instance_double(Bookings::CreateBooking) }
    let(:real_booking) { build_stubbed(:booking, user: student, class_schedule: class_schedule) }

    let(:json_response) { JSON.parse(response.body).deep_symbolize_keys rescue {} }

    subject(:do_action) { post :create, params: request_params }

    context 'when authenticated as a student' do
      before do
        request.headers.merge!(student_headers)

        allow(Bookings::CreateBooking).to receive(:new).with(user: student, class_schedule: class_schedule).and_return(mock_booking_service)
      end

      context 'and the CreateBooking service succeeds' do
        let(:expected_json) { BookingSerializer.new(real_booking).as_json.to_json }

        before do
          allow(mock_booking_service).to receive(:perform).and_return({ success: true, booking: real_booking })
        end

        it 'calls the CreateBooking service' do
          do_action
          expect(Bookings::CreateBooking).to have_received(:new).with(user: student, class_schedule: class_schedule)
          expect(mock_booking_service).to have_received(:perform)
        end

        it 'returns a :created (201) status and the new booking JSON' do
          do_action
          expect(response).to have_http_status(:created)
          expect(response.body).to eq(expected_json)
        end
      end

      context 'and the CreateBooking service fails (e.g., no active pass)' do
        let(:errors) { [ "No active pass found for this academy" ] }

        before { allow(mock_booking_service).to receive(:perform).and_return({ success: false, errors: errors }) }

        it 'calls the CreateBooking service' do
          do_action
          expect(mock_booking_service).to have_received(:perform)
        end

        it 'returns an :unprocessable_entity (422) status and the errors' do
          do_action
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response[:errors]).to match(errors)
        end
      end

      context 'when the class schedule does not exist' do
        let(:request_params) { { academy_id: academy.id, class_schedule_id: 'invalid-id' } }

        it 'returns a :not_found (404) status' do
          do_action
          expect(response).to have_http_status(:not_found)
          expect(json_response[:error]).to eq('Class schedule not found for this academy')
        end
      end

      context 'when the class schedule does not belong to the academy in the URL' do
        let(:request_params) { { academy_id: academy.id, class_schedule_id: other_schedule.id } }

        it 'returns a :not_found (404) status' do
          do_action
          expect(response).to have_http_status(:not_found)
          expect(json_response[:error]).to eq('Class schedule not found for this academy')
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
