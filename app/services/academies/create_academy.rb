# frozen_string_literal: true

module Academies
  class CreateAcademy
    def initialize(user, academy_params)
      @user = user
      @academy_params = academy_params
    end

    def perform
      academy = @user.academies.build(@academy_params)

      return  { success: false, errors: academy.errors.full_messages, academy: nil } unless academy.save

     { success: true, academy: academy }
    end
  end
end
