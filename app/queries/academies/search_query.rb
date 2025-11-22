# frozen_string_literal: true

module Academies
  class SearchQuery
    def initialize(relation = Academy.all)
      @relation = relation
    end

    def by_term(term)
      return self if term.blank?

      @relation = @relation.where(
        "academies.name LIKE :term OR city LIKE :term OR country LIKE :term",
        term: "%#{term}%"
      )
      self
    end

    def by_pass_type(pass_type)
      return self if pass_type.blank?

      @relation = @relation.joins(:passes).where(passes: { pass_type: pass_type }).distinct
      self
    end

    def by_class_day(day_integer)
      return self if day_integer.blank?

      @relation = @relation.joins(:class_schedules).where(class_schedules: { day_of_week: day_integer }).distinct
      self
    end

    def with_amenity_id(amenity_id)
      return self if amenity_id.blank?

      @relation = @relation.joins(:academy_amenities)
                           .where(academy_amenities: { amenity_id: amenity_id })
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