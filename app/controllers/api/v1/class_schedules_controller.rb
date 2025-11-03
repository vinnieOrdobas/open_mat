# frozen_string_literal: true

class Api::V1::ClassSchedulesController < Api::V1::ApplicationController
  before_action :authenticate_request!

  before_action :set_academy_and_authorize_owner!, only: [:create]
  before_action :set_schedule_and_authorize_owner!, only: [:destroy]

  def create
    result = ClassSchedules::CreateSchedule.new(
      academy: @academy,
      params: class_schedule_params
    ).perform

    return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

    render json: serialize_schedule(result[:schedule]), status: :created
  end

  def destroy
    return render json: { errors: @class_schedule.errors.full_messages }, status: :unprocessable_entity unless @class_schedule.destroy

    head :no_content
  end

  private

  def class_schedule_params
    params.require(:class_schedule).permit(
      :title,
      :day_of_week,
      :start_time,
      :end_time
    )
  end

  def serialize_schedule(schedule)
    ClassScheduleSerializer.new(schedule).as_json
  end


  def set_academy_and_authorize_owner!
    @academy = Academy.find_by(id: params[:academy_id])

    return render json: { error: 'Academy not found' }, status: :not_found unless @academy

    return render json: { error: 'Not Authorized' }, status: :unauthorized unless authorize_owner!

    true
  end

  # For DESTROY: Find the specific schedule and authorize
  def set_schedule_and_authorize_owner!
    @class_schedule = ClassSchedule.find_by(id: params[:id])

    return render json: { error: 'Class schedule not found' }, status: :not_found unless @class_schedule

    @academy = @class_schedule.academy

    return render json: { error: 'Not Authorized' }, status: :unauthorized unless authorize_owner!

    true
  end

  def authorize_owner!
    return render json: { error: 'Not Authorized' }, status: :unauthorized unless @academy.user_id == current_user.id

    true
  end
end