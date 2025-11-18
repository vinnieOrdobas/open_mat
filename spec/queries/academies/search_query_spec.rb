# frozen_string_literal: true

RSpec.describe Academies::SearchQuery do
  let!(:amenity_showers) { create(:amenity, name: 'Showers') }
  let!(:amenity_mats) { create(:amenity, name: 'Large Mat Area') }

  let!(:academy_dublin_showers) { create(:academy, name: 'Dublin BJJ', city: 'Dublin', country: 'IE') }
  let!(:academy_dublin_no_showers) { create(:academy, name: 'Dublin No-Gi', city: 'Dublin', country: 'IE') }
  let!(:academy_cork_showers) { create(:academy, name: 'Cork MMA', city: 'Cork', country: 'IE') }
  let!(:academy_london_showers) { create(:academy, name: 'London Grappling', city: 'London', country: 'GB') }

  before do
    create(:academy_amenity, academy: academy_dublin_showers, amenity: amenity_showers)
    create(:academy_amenity, academy: academy_cork_showers, amenity: amenity_showers)
    create(:academy_amenity, academy: academy_london_showers, amenity: amenity_showers)
  end

  describe '#results' do
    it 'returns all academies by default' do
      results = described_class.new.results
      expect(results.count).to eq(4)
    end
  end

  describe '#by_location' do
    it 'finds academies by city name (case-insensitive)' do
      results = described_class.new.by_location('Dublin').results
      expect(results).to contain_exactly(academy_dublin_showers, academy_dublin_no_showers)

      results_lower = described_class.new.by_location('dublin').results
      expect(results_lower).to contain_exactly(academy_dublin_showers, academy_dublin_no_showers)
    end

    it 'finds academies by country code' do
      results = described_class.new.by_location('IE').results
      expect(results).to contain_exactly(academy_dublin_showers, academy_dublin_no_showers, academy_cork_showers)
    end

    it 'finds academies by partial city name' do
      results = described_class.new.by_location('Dub').results
      expect(results).to contain_exactly(academy_dublin_showers, academy_dublin_no_showers)
    end

    it 'returns empty if no match' do
      results = described_class.new.by_location('Paris').results
      expect(results).to be_empty
    end
  end

  describe '#by_city' do
    it 'filters by full city name' do
      results = described_class.new.by_city('Cork').results
      expect(results).to contain_exactly(academy_cork_showers)
    end
  end

  describe '#by_country' do
    it 'filters by country code' do
      results = described_class.new.by_country('GB').results
      expect(results).to contain_exactly(academy_london_showers)
    end
  end

  describe '#with_amenity_id' do
    it 'filters academies that have the specified amenity' do
      results = described_class.new.with_amenity_id(amenity_showers.id).results
      expect(results).to contain_exactly(academy_dublin_showers, academy_cork_showers, academy_london_showers)
    end

    it 'returns an empty relation if no academy has the amenity' do
      results = described_class.new.with_amenity_id(amenity_mats.id).results
      expect(results).to be_empty
    end
  end

  describe 'chaining filters' do
    it 'correctly chains city and country' do
      results = described_class.new.by_city('Dublin').by_country('IE').results
      expect(results).to contain_exactly(academy_dublin_showers, academy_dublin_no_showers)
    end

    it 'correctly chains city and amenity' do
      results = described_class.new.by_city('Dublin').with_amenity_id(amenity_showers.id).results
      expect(results).to contain_exactly(academy_dublin_showers)
    end

    it 'correctly chains country and amenity' do
      results = described_class.new.by_country('IE').with_amenity_id(amenity_showers.id).results
      expect(results).to contain_exactly(academy_dublin_showers, academy_cork_showers)
    end

    it 'correctly chains city, country, and amenity' do
      results = described_class.new.by_city('Cork').by_country('IE').with_amenity_id(amenity_showers.id).results
      expect(results).to contain_exactly(academy_cork_showers)
    end
  end
end
