# frozen_string_literal: true

class Api::V1::ClassSchedulesController < Api::V1::ApplicationController
  before_action :authenticate_request!, except: [ :index ]
  before_action :set_academy, only: [ :index, :create ]
  before_action :set_schedule, only: [ :destroy ]
  before_action :authorize_academy_owner!, only: [ :create ]
  before_action :authorize_schedule_owner!, only: [ :destroy ]

  def index
    @schedules = @academy.class_schedules.order(:day_of_week, :start_time)
    render json: @schedules, each_serializer: ClassScheduleSerializer, status: :ok
  end

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
    params.require(:class_schedule).permit(:title, :day_of_week, :start_time, :end_time)
  end

  def serialize_schedule(schedule)
    ClassScheduleSerializer.new(schedule).as_json
  end


  def set_academy
    @academy = Academy.find(params[:academy_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Academy not found" }, status: :not_found
  end

  def set_schedule
    @class_schedule = ClassSchedule.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Class schedule not found" }, status: :not_found
  end


  def authorize_academy_owner!
    render json: { error: "Not Authorized" }, status: :unauthorized unless @academy.user_id == current_user.id
  end

  def authorize_schedule_owner!
    render json: { error: "Not Authorized" }, status: :unauthorized unless @class_schedule.academy.user_id == current_user.id
  end
end
