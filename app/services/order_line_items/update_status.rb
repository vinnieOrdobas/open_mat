# frozen_string_literal: true

module OrderLineItems
  class UpdateStatus
    # Valid transitions an owner can make
    VALID_OWNER_TRANSITIONS = {
      "pending_approval" => %w[approved rejected]
    }.freeze

    def initialize(line_item:, new_status:)
      @line_item = line_item
      @new_status = new_status
    end

    def perform
      return { success: false, errors: [ "'#{@new_status}' is not a valid status" ] } unless valid_status?(@new_status)

      return { success: false, errors: [ "Cannot transition from '#{@line_item.status}' to '#{@new_status}'" ] } unless valid_transition?(@line_item.status, @new_status)

      return { success: false, errors: @line_item.errors.full_messages } unless @line_item.update(status: @new_status)

      { success: true, line_item: @line_item }
    end

    private

    def valid_status?(status)
      return false unless OrderLineItem.statuses.key?(status)

      true
    end

    def valid_transition?(from_status, to_status)
      return false unless  VALID_OWNER_TRANSITIONS[from_status]&.include?(to_status)

      true
    end
  end
end
