# frozen_string_literal: true

module Academies
  class SearchQuery
    def initialize(relation = Academy.all)
      @relation = relation
    end

    # --- 1. Smart Search ---
    def by_term(term)
      return self if term.blank?

      @relation = @relation.where(
        "academies.name LIKE :term OR city LIKE :term OR country LIKE :term",
        term: "%#{term}%"
      )
      self
    end

    def by_pass_types(pass_types)
      return self if pass_types.blank?

      @relation = @relation.joins(:passes).where(passes: { pass_type: pass_types }).distinct
      self
    end

    def by_class_days(days)
      return self if days.blank?

      @relation = @relation.joins(:class_schedules).where(class_schedules: { day_of_week: days }).distinct
      self
    end

    def with_amenity_ids(amenity_ids)
      return self if amenity_ids.blank?

      amenity_ids = amenity_ids.uniq
      @relation = @relation.joins(:academy_amenities)
                           .where(academy_amenities: { amenity_id: amenity_ids })
                           .group("academies.id")
                           .having("COUNT(DISTINCT academy_amenities.amenity_id) >= ?", amenity_ids.size)
      self
    end

    def by_countries(country_codes)
      return self if country_codes.blank?

      @relation = @relation.where(country: country_codes)
      self
    end

    def results
      Academy.includes(
        :attachments,
        :amenities,
        :passes,
        :reviews,
        :class_schedules
      ).where(id: @relation.ids)
    end
  end
end
