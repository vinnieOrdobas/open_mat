# frozen_string_literal: true

RSpec.describe 'Api::V1::Reviews Workflow', type: :request do
  let!(:student) { create(:user, role: 'student') }
  let!(:other_student) { create(:user, role: 'student') }
  let!(:owner) { create(:user, :owner) }

  let!(:academy) { create(:academy, user: owner) }

  let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student.id)}", 'Content-Type' => 'application/json' } }
  let(:other_student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: other_student.id)}", 'Content-Type' => 'application/json' } }

  let(:json_response) { JSON.parse(response.body).deep_symbolize_keys rescue {} }

  let(:reviews_url) { "/api/v1/academies/#{academy.id}/reviews" }
  let(:academy_profile_url) { "/api/v1/academies/#{academy.id}" }

  let(:review_params) { { review: { rating: 5, comment: 'Loved it!' } }.to_json }

  describe 'POST /api/v1/academies/:academy_id/reviews' do
    context 'when the user has NOT attended the academy (no booking)' do
      it 'prevents the review and returns an error' do
        expect { post reviews_url, headers: student_headers, params: review_params }.not_to change(Review, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include('You can only review academies you have booked a class with')
      end
    end

    context 'when the user HAS attended (has a booking)' do
      let!(:schedule) { create(:class_schedule, academy: academy) }
      let!(:booking) { create(:booking, user: student, class_schedule: schedule) }

      it 'creates a new review' do
        expect { post reviews_url, headers: student_headers, params: review_params }.to change(Review, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response[:rating]).to eq(5)
        expect(json_response[:comment]).to eq('Loved it!')
        expect(json_response[:username]).to eq(student.username)
      end

      it 'prevents the user from reviewing a second time' do
        post reviews_url, headers: student_headers, params: review_params
        expect(response).to have_http_status(:created)

        expect { post reviews_url, headers: student_headers, params: { review: { rating: 1, comment: 'Changed my mind' } }.to_json }.not_to change(Review, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include('User has already reviewed this academy')
      end
    end
  end

  # ... (The rest of the file: PATCH, DELETE, GET specs remain valid and unchanged) ...
  describe 'PATCH /api/v1/academies/:academy_id/reviews/:id' do
    let!(:review) { create(:review, user: student, academy: academy, rating: 3) }
    let(:update_url) { "/api/v1/academies/#{academy.id}/reviews/#{review.id}" }
    let(:update_params) { { review: { rating: 5, comment: 'Updated!' } }.to_json }

    context 'when authenticated as the review author' do
      it 'updates their review' do
        patch update_url, headers: student_headers, params: update_params

        expect(response).to have_http_status(:ok)
        expect(json_response[:rating]).to eq(5)
        expect(json_response[:comment]).to eq('Updated!')
        expect(review.reload.rating).to eq(5)
      end
    end

    context 'when authenticated as a different user' do
      it 'returns unauthorized' do
        patch update_url, headers: other_student_headers, params: update_params

        expect(response).to have_http_status(:unauthorized)
        expect(review.reload.rating).to eq(3)
      end
    end
  end

  describe 'DELETE /api/v1/academies/:academy_id/reviews/:id' do
    let!(:review) { create(:review, user: student, academy: academy) }
    let(:delete_url) { "/api/v1/academies/#{academy.id}/reviews/#{review.id}" }

    context 'when authenticated as the review author' do
      it 'deletes their review' do
        expect { delete delete_url, headers: student_headers }.to change(Review, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when authenticated as a different user' do
      it 'returns unauthorized' do
        expect { delete delete_url, headers: other_student_headers }.not_to change(Review, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/academies/:id (Public Profile)' do
    let!(:review1) { create(:review, academy: academy, user: student, rating: 5) }
    let!(:review2) { create(:review, academy: academy, user: other_student, rating: 3) }

    it 'is public and includes the average rating and review list' do
      get academy_profile_url

      expect(response).to have_http_status(:ok)
      expect(json_response[:average_rating]).to eq(4.0)

      expect(json_response[:reviews]).to be_an(Array)
      expect(json_response[:reviews].count).to eq(2)
    end
  end

  describe 'GET /api/v1/academies/:id/reviews (Public List)' do
    let!(:review1) { create(:review, academy: academy, user: student, rating: 5) }
    let!(:review2) { create(:review, academy: academy, user: other_student, rating: 3) }

    it 'is public and returns the list of reviews' do
      get reviews_url

      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body).map { |o| o.deep_symbolize_keys }

      expect(parsed_response.count).to eq(2)
      expect(parsed_response.first[:rating]).to eq(5)
    end
  end
end
