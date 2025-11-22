# frozen_string_literal: true

class Api::V1::CountriesController < Api::V1::ApplicationController
  def index
    countries = Academy.distinct.pluck(:country).compact.sort
    render json: countries.map { |c| { value: c, label: c } }, status: :ok
  end
end
