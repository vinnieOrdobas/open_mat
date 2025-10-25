# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSerializer, type: :serializer do
  let!(:user) do
    User.new(
      id: 1,
      firstname: 'Test',
      lastname: 'User',
      email: 'test@example.com',
      username: 'testuser',
      password_digest: 'a-very-secret-hash', # The field we want to hide
      role: 'student',
      belt_rank: 'white',
      created_at: Time.current,
      updated_at: Time.current
    )
  end

  # This is how we invoke the serializer and get its output as a Ruby hash
  let(:json) { UserSerializer.new(user).as_json }

  # These are the only keys we ever expect to see
  let(:expected_keys) do
    [
      :id, :username, :email, :firstname, :lastname,
      :role, :belt_rank, :created_at, :updated_at
    ]
  end

  it 'includes all the expected attributes' do
    expect(json.keys).to contain_exactly(*expected_keys)
  end

  it 'returns the correct values for the attributes' do
    expect(json[:id]).to eq(user.id)
    expect(json[:username]).to eq(user.username)
    expect(json[:role]).to eq(user.role)
  end

  it 'formats the timestamps using the ApplicationSerializer (ISO8601)' do
    expect(json[:created_at]).to eq(user.created_at.iso8601)
    expect(json[:updated_at]).to eq(user.updated_at.iso8601)
  end

  it 'does NOT include the password_digest' do
    expect(json.keys).not_to include(:password_digest)
  end
end
