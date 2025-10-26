# frozen_string_literal: true

module Sessions
  class AuthenticateUser
    def initialize(email, password)
      @email = email
      @password = password
    end

    def authenticate
      return unless user&.authenticate(@password)

      user
    end

    def user
      @user ||= User.find_by_email(@email)
    end
  end
end
