# frozen_string_literal: true

module Academies
  class UpdateAcademy
    def initialize(academy, academy_params)
      @academy = academy
      @academy_params = academy_params
    end

    # Our explicit method name
    def perform
      return { success: false, errors: @academy.errors.full_messages, academy: nil } unless @academy.update(@academy_params)

      { success: true, academy: @academy }
    end
  end
end
