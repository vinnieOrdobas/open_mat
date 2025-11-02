# frozen_string_literal: true

module Passes
  class ActivatePasses
    def initialize(line_item:)
      @line_item = line_item
      @pass = line_item.pass
      @user = line_item.order.user
    end

    def perform
      student_pass = StudentPass.new(
        user: @user,
        pass: @pass,
        order_line_item: @line_item,
        academy: @pass.academy,
        status: "active"
      )
      set_expire_attributes(student_pass)

      return { success: false, errors: student_pass.errors.full_messages } unless student_pass.save

      { success: true, student_pass: student_pass }
    end

    private

    def set_expire_attributes(student_pass)
      case @pass.pass_type
      when "day_pass"
        student_pass.expires_at = Time.current + 1.day
      when "week_pass"
        student_pass.expires_at = Time.current + 1.week
      when "month_pass"
        student_pass.expires_at = Time.current + 1.month
      when "punch_card"
        student_pass.credits_remaining = @pass.class_credits
      when "single"
        student_pass.credits_remaining = 1
      end
    end
  end
end
