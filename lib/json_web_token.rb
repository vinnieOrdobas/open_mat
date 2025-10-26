# frozen_string_literal: true

require "jwt"
module JsonWebToken
  # The constant stays at the top level of the module
  SECRET_KEY = Rails.application.credentials.secret_key_base

  class << self
    def encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY)
    end

    def decode(token)
      decoded = JWT.decode(token, SECRET_KEY).first
      HashWithIndifferentAccess.new(decoded)
    rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
      nil
    end
  end
end
