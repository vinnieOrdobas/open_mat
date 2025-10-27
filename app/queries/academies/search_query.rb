# frozen_string_literal: true

module Academies
  class SearchQuery
    def initialize(relation = Academy.all)
      @relation = relation
    end

    def by_city(city)
      return self if city.blank?

      @relation = @relation.where("city ILIKE ?", "%#{city}%")
      self
    end

    def by_country(country_code)
      return self if country_code.blank?

      @relation = @relation.where("country ILIKE ?", country_code)
      self
    end

    def with_amenity_id(amenity_id)
      return self if amenity_id.blank?

      @relation = @relation.joins(:academy_amenities)
                           .where(academy_amenities: { amenity_id: amenity_id })
      self
    end

    def results
      @relation
    end
  end
end
