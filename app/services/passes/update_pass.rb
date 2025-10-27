# frozen_string_literal: true

module Passes
  class UpdatePass
    def initialize(pass, pass_params)
      @pass = pass
      @pass_params = pass_params
    end

    def perform
      return { success: false, errors: @pass.errors.full_messages, pass: nil } unless @pass.update(@pass_params)

      { success: true, pass: @pass }
    end
  end
end
