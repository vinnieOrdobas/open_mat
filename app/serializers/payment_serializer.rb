# frozen_string_literal: true

class PaymentSerializer < ApplicationSerializer
  attributes :id,
             :order_id,
             :status,
             :amount_cents,
             :currency,
             :processor,
             :processor_id, # The mock ID
             :created_at,
             :updated_at
end
