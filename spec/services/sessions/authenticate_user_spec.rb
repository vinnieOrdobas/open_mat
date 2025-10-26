# frozen_string_literal: true

RSpec.describe Sessions::AuthenticateUser do
  describe '#authenticate' do
    let(:email) { 'test@example.com' }
    let(:password) { 'password123' }

    let!(:user) { create(:user, email: email, password: password) }

    # Memoize the service instance
    let(:service) { described_class.new(email, password) }

    context 'with valid credentials' do
      it 'returns the user object' do
        expect(service.authenticate).to eq(user)
      end
    end

    context 'with an invalid password' do
      let(:service_with_bad_pass) { described_class.new(email, 'wrong-password') }

      it 'returns nil' do
        expect(service_with_bad_pass.authenticate).to be_nil
      end
    end

    context 'with an invalid email (user not found)' do
      let(:service_with_bad_email) { described_class.new('nonexistent@example.com', password) }

      it 'returns nil' do
        expect(service_with_bad_email.authenticate).to be_nil
      end
    end
  end
end
