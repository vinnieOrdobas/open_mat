# frozen_string_literal: true

RSpec.describe Academies::SearchQuery do
  # --- Setup Data ---
  let!(:amenity_showers) { create(:amenity, name: 'Showers') }
  let!(:amenity_mats) { create(:amenity, name: 'Large Mat Area') }

  let!(:academy_dublin) { create(:academy, name: 'Dublin BJJ', city: 'Dublin', country: 'IE') }
  let!(:academy_cork) { create(:academy, name: 'Cork MMA', city: 'Cork', country: 'IE') }
  let!(:academy_london) { create(:academy, name: 'London Grappling', city: 'London', country: 'GB') }
  let!(:academy_ny) { create(:academy, name: 'Renzo NYC', city: 'New York', country: 'US') }

  before do
    create(:pass, :day_pass, academy: academy_dublin)
    create(:pass, :month_pass, academy: academy_cork)
    create(:class_schedule, academy: academy_london, day_of_week: 1)
    create(:class_schedule, academy: academy_dublin, day_of_week: 2)
    create(:academy_amenity, academy: academy_dublin, amenity: amenity_showers)
    create(:academy_amenity, academy: academy_dublin, amenity: amenity_mats)
    create(:academy_amenity, academy: academy_cork, amenity: amenity_showers)
  end

  describe '#results' do
    it 'returns all academies by default' do
      expect(described_class.new.results.count).to eq(4)
    end
  end

  describe '#by_term' do
    it 'finds academies by name' do
      expect(described_class.new.by_term('Grappling').results).to contain_exactly(academy_london)
    end
  end

  describe '#by_pass_types' do
    it 'finds academies by single pass type' do
      expect(described_class.new.by_pass_types([ 'day_pass' ]).results).to contain_exactly(academy_dublin)
    end

    it 'finds academies by multiple pass types (OR logic)' do
      results = described_class.new.by_pass_types([ 'day_pass', 'month_pass' ]).results
      expect(results).to contain_exactly(academy_dublin, academy_cork)
    end
  end

  describe '#by_class_days' do
    it 'finds academies by single class day' do
      expect(described_class.new.by_class_days([ 1 ]).results).to contain_exactly(academy_london)
    end

    it 'finds academies by multiple class days (OR logic)' do
      expect(described_class.new.by_class_days([ 1, 2 ]).results).to contain_exactly(academy_london, academy_dublin)
    end
  end

  describe '#with_amenity_ids' do
    it 'filters by multiple amenities (AND logic)' do
      ids = [ amenity_showers.id, amenity_mats.id ]
      expect(described_class.new.with_amenity_ids(ids).results).to contain_exactly(academy_dublin)
    end
  end

  describe '#by_countries' do
    it 'filters by multiple country codes (OR logic)' do
      expect(described_class.new.by_countries([ 'IE', 'GB' ]).results)
        .to contain_exactly(academy_dublin, academy_cork, academy_london)
    end
  end
end
