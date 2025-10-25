# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AcademyAmenity, type: :model do
  describe 'associations' do
    it { should belong_to(:academy) }
    it { should belong_to(:amenity) }
  end

  describe 'validations' do
    it 'validates uniqueness of amenity_id scoped to academy_id' do
      user = User.create!(firstname: 'Owner', lastname: 'One', email: 'owner@example.com', username: 'owner1', password: 'password', role: 'owner')
      academy = Academy.create!(user: user, name: 'Test Academy', email: 'academy@example.com', street_address: '123 Main St', city: 'Anytown', country: 'USA')
      amenity = Amenity.create!(name: 'Showers', category: 'facilities')

      AcademyAmenity.create!(academy: academy, amenity: amenity)

      subject { AcademyAmenity.new(academy: academy, amenity: amenity) }

      expect(subject).to validate_uniqueness_of(:amenity_id).scoped_to(:academy_id)
    end
  end
end
