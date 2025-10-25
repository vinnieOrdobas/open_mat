# frozen_string_literal: true

# app/services/users/register_user.rb
module Users
  class RegisterUser
    def initialize(user_params)
      @user_params = user_params
    end


    def register
      user = User.new(@user_params)

      return { success: false, errors: user.errors.full_messages } unless user.save

      { success: true, user: user }
    end
  end
end
