# frozen_string_literal: true

class Api::V1::BookingsController < Api::V1::ApplicationController
  before_action :authenticate_request!
  before_action :set_class_schedule

  def create
    result = Bookings::CreateBooking.new(
      user: current_user,
      class_schedule: @class_schedule
    ).perform

    return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

    render json: serialize_booking(result[:booking]), status: :created
  end

  private

  def set_class_schedule
    @class_schedule = ClassSchedule.find_by(id: params[:class_schedule_id])

    render json: { error: "Class schedule not found for this academy" }, status: :not_found unless correct_academy?
  end

  def correct_academy?
    @class_schedule&.academy_id == params[:academy_id].to_i
  end

  def serialize_booking(booking)
    BookingSerializer.new(booking).as_json
  end
end
