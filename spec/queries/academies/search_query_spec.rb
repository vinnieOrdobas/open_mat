# frozen_string_literal: true

RSpec.describe Academies::SearchQuery do
  let(:owner) { create(:user, :owner) }
  let(:owner_1) { create(:user, :owner) }
  let(:owner_2) { create(:user, :owner) }
  let!(:academy_dublin) { create(:academy, name: 'Dublin BJJ', city: 'Dublin', country: 'IE', user: owner) }
  let!(:academy_cork) { create(:academy, name: 'Cork MMA', city: 'Cork', country: 'IE', user: owner_1) }
  let!(:academy_london) { create(:academy, name: 'London Grappling', city: 'London', country: 'GB', user: owner_2) }

  before do
    create(:pass, :day_pass, academy: academy_dublin)
    create(:pass, :month_pass, academy: academy_cork)
    create(:class_schedule, academy: academy_london, day_of_week: 1)
    create(:class_schedule, academy: academy_dublin, day_of_week: 2)
  end

  describe '#results' do
    it 'returns all academies by default' do
      results = described_class.new.results
      expect(results.count).to eq(3)
    end
  end

  describe '#by_term' do
    it 'finds academies by name' do
      results = described_class.new.by_term('Grappling').results
      expect(results).to contain_exactly(academy_london)
    end

    it 'finds academies by city' do
      results = described_class.new.by_term('Dublin').results
      expect(results).to contain_exactly(academy_dublin)
    end

    it 'finds academies by country' do
      results = described_class.new.by_term('IE').results
      expect(results).to contain_exactly(academy_dublin, academy_cork)
    end

    it 'finds academies by partial match' do
      results = described_class.new.by_term('Dub').results
      expect(results).to contain_exactly(academy_dublin)
    end
  end

  describe '#by_pass_type' do
    it 'finds academies offering a specific pass type' do
      results = described_class.new.by_pass_type('day_pass').results
      expect(results).to contain_exactly(academy_dublin)

      results_month = described_class.new.by_pass_type('month_pass').results
      expect(results_month).to contain_exactly(academy_cork)
    end
  end

  describe '#by_class_day' do
    it 'finds academies with classes on a specific day' do
      results = described_class.new.by_class_day(1).results
      expect(results).to contain_exactly(academy_london)

      results_tue = described_class.new.by_class_day(2).results
      expect(results_tue).to contain_exactly(academy_dublin)
    end
  end
end
