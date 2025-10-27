# frozen_string_literal: true

module Passes
  class CreatePass
    def initialize(academy, pass_params)
      @academy = academy
      @pass_params = pass_params
    end

    def perform
      pass = @academy.passes.build(@pass_params)

      return { success: false, errors: pass.errors.full_messages, pass: nil } unless pass.save

      { success: true, pass: pass }
    end
  end
end
