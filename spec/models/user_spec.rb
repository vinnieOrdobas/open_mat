# frozen_string_literal: true

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:academies).dependent(:restrict_with_error) }
    it { should have_many(:orders).dependent(:destroy) }
    it { should have_many(:attachments).dependent(:destroy) }
    it { should have_one(:headshot).dependent(:destroy) }
  end

  describe 'validations' do
    # We must create a user first for the uniqueness specs to work
    subject { User.new(firstname: 'John', lastname: 'Doe', email: 'john@example.com', username: 'johndoe', password: 'password', role: 'student') }

    it { should validate_presence_of(:firstname) }
    it { should validate_presence_of(:lastname) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value('test@example.com').for(:email) }
    it { should_not allow_value('test.example.com').for(:email) }

    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username) }

    it { should validate_presence_of(:role) }

    it { should define_enum_for(:role).with_values(student: 'student', owner: 'owner', admin: 'admin').backed_by_column_of_type(:string) }
    it { should define_enum_for(:belt_rank).with_values(white: 'white', blue: 'blue', purple: 'purple', brown: 'brown', black: 'black').backed_by_column_of_type(:string) }

    it { should have_secure_password }
  end

  describe 'headshot association' do
  let(:user) { create(:user) }
  let(:headshot) { create(:attachment, :headshot, attachable: user) }
  let(:attachment) { create(:attachment, :photo, attachable: user) }

  before do
    headshot
    attachment
  end

  it 'correctly finds the headshot' do
    expect(user.headshot).to eq(headshot)
    expect(user.attachments.count).to eq(2)
  end
  end
end
