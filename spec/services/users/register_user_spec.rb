# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::RegisterUser do
  describe '#register' do
    let(:valid_params) do
      {
        firstname: 'Test',
        lastname: 'User',
        email: 'test@example.com',
        username: 'testuser',
        password: 'password123',
        password_confirmation: 'password123'
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect { described_class.new(valid_params).register }.to change(User, :count).by(1)
      end

      it 'returns a success result with the new user' do
        result = described_class.new(valid_params).register

        expect(result[:success]).to be(true)
        expect(result[:user]).to be_a(User)
        expect(result[:user].email).to eq('test@example.com')
        expect(result[:errors]).to be_nil
      end

      it 'assigns the default role of "student" to the new user' do
        result = described_class.new(valid_params).register
        expect(result[:user].role).to eq('student')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { valid_params.merge(email: nil) }

      it 'does not create a new user' do
        expect { described_class.new(invalid_params).register }.not_to change(User, :count)
      end

      it 'returns a failure result with errors' do
        result = described_class.new(invalid_params).register

        expect(result[:success]).to be(false)
        expect(result[:user]).to be_nil
        expect(result[:errors]).to be_an(Array)
        expect(result[:errors]).to include("Email can't be blank")
      end
    end

    context 'with mismatched passwords' do
      let(:mismatched_params) { valid_params.merge(password_confirmation: 'wrong') }

      it 'returns a failure result with password confirmation error' do
        result = described_class.new(mismatched_params).register

        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Password confirmation doesn't match Password")
      end
    end
  end
end
