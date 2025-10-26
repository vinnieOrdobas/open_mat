# frozen_string_literal: true

require 'rails_helper'
require 'json_web_token'
require 'timecop'

RSpec.describe JsonWebToken do
  let(:secret_key) { Rails.application.credentials.secret_key_base }
  let(:payload) { { user_id: 1, email: 'test@example.com' } }

  describe '.encode' do
    it 'returns a JWT token string' do
      token = described_class.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3)
    end

    it 'includes the payload in the token' do
      token = described_class.encode(payload)
      decoded_payload = JWT.decode(token, secret_key, true, { algorithm: 'HS256' }).first

      expect(decoded_payload['user_id']).to eq(payload[:user_id])
      expect(decoded_payload['email']).to eq(payload[:email])
    end

    it 'includes the expiration (exp) claim' do
      token = described_class.encode(payload)
      decoded_payload = JWT.decode(token, secret_key, true, { algorithm: 'HS256' }).first

      expect(decoded_payload['exp']).not_to be_nil
      expect(decoded_payload['exp']).to be > Time.now.to_i
    end
  end

  describe '.decode' do
    let(:valid_token) { described_class.encode(payload) }

    context 'with a valid token' do
      it 'returns the payload as a HashWithIndifferentAccess' do
        decoded = described_class.decode(valid_token)

        expect(decoded).to be_a(HashWithIndifferentAccess)
        expect(decoded[:user_id]).to eq(payload[:user_id])
        expect(decoded['user_id']).to eq(payload[:user_id])
        expect(decoded[:email]).to eq(payload[:email])
      end
    end

    context 'with an expired token' do
      it 'returns nil' do
        Timecop.freeze(Time.current) do
          expired_token = described_class.encode(payload, 1.second.ago)
          decoded = described_class.decode(expired_token)
          expect(decoded).to be_nil
        end
      end
    end

    context 'with an invalid signature token' do
      it 'returns nil' do
        fake_secret = 'not-the-real-secret'
        invalid_token = JWT.encode(payload, fake_secret)

        decoded = described_class.decode(invalid_token)
        expect(decoded).to be_nil
      end
    end

    context 'with an invalid token (e.g., just text)' do
      it 'returns nil' do
        invalid_token = 'just.random.text'
        decoded = described_class.decode(invalid_token)
        expect(decoded).to be_nil
      end
    end
  end
end
