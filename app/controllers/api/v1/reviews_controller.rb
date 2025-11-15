# frozen_string_literal: true

class Api::V1::ReviewsController < Api::V1::ApplicationController
  before_action :authenticate_request!, except: %i[index]

  before_action :set_academy, only: %i[index create]

  before_action :set_review_and_authorize_author!, only: %i[update destroy]

  def index
    reviews = @academy.reviews.includes(:user)

    render json: reviews.map { |review| serialize_review(review) }, status: :ok
  end

  def create
    result = Reviews::CreateReview.new(
      user: current_user,
      academy: @academy,
      params: review_params
    ).perform

    return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

    render json: serialize_review(result[:review]), status: :created
  end

  def update
    return render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity unless @review.update(review_params)

    render json: serialize_review(@review), status: :ok
  end

  def destroy
    return render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity unless @review.destroy

    head :no_content
  end

  private

  def review_params
    params.require(:review).permit(:rating, :comment)
  end

  def serialize_review(review)
    ReviewSerializer.new(review).as_json
  end

  def set_academy
    @academy = Academy.find_by(id: params[:academy_id])

    render json: { error: "Academy not found" }, status: :not_found unless @academy
  end

  def set_review_and_authorize_author!
    @review = Review.find_by(id: params[:id])

    return render json: { error: "Review not found" }, status: :not_found unless @review

    render json: { error: "Not Authorized" }, status: :unauthorized unless @review.user_id == current_user.id
  end
end
