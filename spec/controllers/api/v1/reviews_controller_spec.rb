# frozen_string_literal: true

RSpec.describe Api::V1::ReviewsController, type: :controller do
  let!(:student) { create(:user, role: 'student') }
  let!(:other_student) { create(:user, role: 'student') } # For auth tests
  let!(:owner) { create(:user, :owner) }
  let!(:academy) { create(:academy, user: owner) }

  let(:student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: student.id)}" } }
  let(:other_student_headers) { { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: other_student.id)}" } }

  let(:json_response) { JSON.parse(response.body).deep_symbolize_keys rescue {} }

  describe 'POST #create' do
    subject(:do_action) { post :create, params: request_params }

    let(:valid_params) { { rating: '5', comment: 'Amazing!' } }
    let(:request_params) { { academy_id: academy.id, review: valid_params } }
    let(:permitted_params) { ActionController::Parameters.new(valid_params).permit! }

    let(:mock_create_service) { instance_double(Reviews::CreateReview) }
    let(:real_review) { build_stubbed(:review, user: student, academy: academy, **valid_params) }

    context 'when authenticated as a student' do
      let(:expected_json) { ReviewSerializer.new(real_review).as_json.to_json }

      before do
        request.headers.merge!(student_headers)
        allow(Reviews::CreateReview).to receive(:new).with(user: student, academy: academy, params: permitted_params).and_return(mock_create_service)
      end

      context 'and the CreateReview service succeeds' do
        before do
          allow(mock_create_service).to receive(:perform).and_return({ success: true, review: real_review })
        end

        it 'calls the CreateReview service' do
          do_action
          expect(Reviews::CreateReview).to have_received(:new)
          expect(mock_create_service).to have_received(:perform)
        end

        it 'returns a :created (201) status and the new review JSON' do
          do_action
          expect(response).to have_http_status(:created)
          expect(response.body).to eq(expected_json)
        end
      end

      context 'and the service fails (e.g., user has not attended)' do
        let(:errors) { [ "You can only review academies you have attended" ] }

        before { allow(mock_create_service).to receive(:perform).and_return({ success: false, errors: errors }) }

        it 'returns an :unprocessable_entity (422) status and the errors' do
          do_action
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response[:errors]).to match(errors)
        end
      end

      context 'and the service fails (e.g., user has already reviewed)' do
        let(:errors) { [ "User has already reviewed this academy" ] }

        before { allow(mock_create_service).to receive(:perform).and_return({ success: false, errors: errors }) }

        it 'returns an :unprocessable_entity (422) status' do
          do_action
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response[:errors]).to match(errors)
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

  describe 'PATCH #update' do
    let!(:review) { create(:review, user: student, academy: academy, rating: 3) }

    let(:update_params) { { review: { rating: 5, comment: 'Updated!' } } }
    let(:request_params) { { academy_id: academy.id, id: review.id, review: update_params[:review] } }

    subject(:do_action) { patch :update, params: request_params }

    context 'when authenticated as the review author' do
      before { request.headers.merge!(student_headers) }

      it 'returns an :ok (200) status' do
        do_action
        expect(response).to have_http_status(:ok)
      end

      it 'updates the review in the database' do
        do_action

        review.reload
        expect(review.rating).to eq(5)
        expect(review.comment).to eq('Updated!')
      end

      it 'returns the updated review JSON' do
        do_action
        expect(json_response[:rating]).to eq(5)
        expect(json_response[:comment]).to eq('Updated!')
      end

      context 'with invalid parameters' do
        let(:update_params) { { review: { rating: 99 } } }

        it 'returns an :unprocessable_entity (422) status' do
          do_action
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns the validation errors' do
          do_action
          expect(json_response[:errors]).to include("Rating must be between 1 and 5")
        end
      end
    end

    context 'when authenticated as a different user (not the author)' do
      before { request.headers.merge!(other_student_headers) }

      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Not Authorized')
      end

      it 'does not update the review' do
        do_action
        expect(review.reload.rating).to eq(3)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:review) { create(:review, user: student, academy: academy) }

    let(:request_params) { { academy_id: academy.id, id: review.id } }

    subject(:do_action) { delete :destroy, params: request_params }

    context 'when authenticated as the review author' do
      before { request.headers.merge!(student_headers) }

      it 'destroys the review' do
        expect { do_action }.to change(Review, :count).by(-1)
      end

      it 'returns a :no_content (204) status' do
        do_action
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when authenticated as a different user (not the author)' do
      before { request.headers.merge!(other_student_headers) }

      it 'does not destroy the review' do
        expect { do_action }.not_to change(Review, :count)
      end

      it 'returns an :unauthorized (401) status' do
        do_action
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the review ID does not belong to the academy ID' do
      let(:request_params) { { academy_id: academy.id, id: 999999 } }

      before { request.headers.merge!(student_headers) }

      it 'returns a :not_found (404) status' do
        do_action
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
