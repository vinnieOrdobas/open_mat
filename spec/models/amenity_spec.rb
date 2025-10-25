# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Amenity, type: :model do
  describe 'associations' do
    it { should have_many(:academy_amenities).dependent(:destroy) }
    it { should have_many(:academies).through(:academy_amenities) }
  end

  describe 'validations' do
    subject { Amenity.new(name: 'Showers', category: 'facilities') }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it { should validate_presence_of(:category) }
    it { should define_enum_for(:category).with_values(facilities: 'facilities', equipment: 'equipment', convenience: 'convenience').backed_by_column_of_type(:string) }
  end
end
