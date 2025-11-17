# frozen_string_literal: true

RSpec.describe Attachment, type: :model do
  describe 'associations' do
    it { should belong_to(:attachable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:kind) }

    it { should_not validate_presence_of(:url) }

    it 'is valid without a url' do
      attachment = build(:attachment, url: nil)
      expect(attachment).to be_valid
    end
  end
end
