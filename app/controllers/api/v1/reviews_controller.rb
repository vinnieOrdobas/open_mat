# frozen_string_literal: true

class Api::V1::ReviewsController < Api::V1::ApplicationController
  before_action :authenticate_request!
  before_action :set_academy, only: [:create]

  before_action :set_review_and_authorize_author!, only: [:update, :destroy]


  def create
    return render json: { errors: ["You can only review academies you have attended"] }, status: :forbidden unless user_has_attended_academy?


    @review = @academy.reviews.build(review_params)
    @review.user = current_user # Assign the author

    if @review.save
      render json: serialize_review(@review), status: :created
    else
      # Handles validation errors (e.g., rating 1-5, already reviewed)
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/academies/:academy_id/reviews/:id
  def update
    # @review is already set and authorized by the before_action
    if @review.update(review_params)
      render json: serialize_review(@review), status: :ok
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/academies/:academy_id/reviews/:id
  def destroy
    # @review is already set and authorized by the before_action
    if @review.destroy
      head :no_content
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # --- Strong Params ---
  def review_params
    # Only allow rating and comment
    params.require(:review).permit(:rating, :comment)
  end

  # --- Serializer Helper ---
  def serialize_review(review)
    ReviewSerializer.new(review).as_json
  end

  # --- Finders (before_actions) ---

  # Finds the Academy from the URL (for create)
  def set_academy
    @academy = Academy.find_by(id: params[:academy_id])
    render json: { error: 'Academy not found' }, status: :not_found unless @academy
  end

  # Finds the Review from the URL and authorizes its author (for update, destroy)
  def set_review_and_authorize_author!
    @review = Review.find_by(id: params[:id])

    # Check 1: Does the review exist?
    unless @review
      return render json: { error: 'Review not found' }, status: :not_found
    end

    # Check 2: Does the review belong to the academy in the URL? (for consistency)
    unless @review.academy_id == params[:academy_id].to_i
      return render json: { error: 'Review not found for this academy' }, status: :not_found
    end

    # Check 3: Is the current_user the author?
    unless @review.user_id == current_user.id
      render json: { error: 'Not Authorized' }, status: :unauthorized
    end
  end

  # --- Validation Helper (Task 10 Logic) ---

  # Checks if the user has a "used" pass for this academy
  def user_has_attended_academy?
    current_user.student_passes.exists?(
      academy_id: @academy.id,
      status: ['expired', 'depleted'] # Statuses that imply use
    )
  end
end