# frozen_string_literal: true

RSpec.describe 'Api::V1::Booking Workflow', type: :request do
  let!(:student) { create(:user, role: 'student') }
  let!(:owner) { create(:user, :owner) }
  let!(:academy) { create(:academy, user: owner) }
  let!(:class_schedule) { create(:class_schedule, academy: academy) }

  let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student.id)}", 'Content-Type' => 'application/json' } }

  let(:booking_url) { "/api/v1/academies/#{academy.id}/class_schedules/#{class_schedule.id}/bookings" }

  let(:json_response) { JSON.parse(response.body).deep_symbolize_keys rescue {} }

  context 'when the student has NO active pass' do
    it 'prevents the booking and returns an error' do
      expect { post booking_url, headers: student_headers }.not_to change(Booking, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response[:errors]).to include('No active pass found for this academy')
    end
  end

  context 'when the student HAS an active pass' do
    let!(:student_pass) { create(:student_pass, :credit_based, user: student, academy: academy, credits_remaining: 5, status: 'active') }

    it 'allows the student to book the class' do
      expect { post booking_url, headers: student_headers }.to change(Booking, :count).by(1)

      expect(response).to have_http_status(:created)

      expect(json_response[:id]).to eq(Booking.last.id)
      expect(json_response[:class_schedule][:id]).to eq(class_schedule.id)
      expect(json_response[:student_pass][:id]).to eq(student_pass.id)
    end

    it 'redeems the pass (decrements credits)' do
      post booking_url, headers: student_headers
      expect(student_pass.reload.credits_remaining).to eq(4)
      expect(student_pass.status).to eq('active')
    end

    it 'prevents the student from double-booking the same class' do
      post booking_url, headers: student_headers
      expect(response).to have_http_status(:created)
      expect { post booking_url, headers: student_headers }.not_to change(Booking, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response[:errors]).to include('Validation failed: User has already booked this class')
    end
  end

  context 'when the student has an EXPIRED pass' do
    let!(:student_pass) { create(:student_pass, :time_based, user: student, academy: academy, expires_at: 1.day.ago, status: 'active') }

    it 'prevents the booking and marks the pass as expired' do
      expect { post booking_url, headers: student_headers }.not_to change(Booking, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response[:errors]).to include('No active pass found for this academy')
      expect(student_pass.reload.status).to eq('expired')
    end
  end
end
