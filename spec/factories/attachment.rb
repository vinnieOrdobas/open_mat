# frozen_string_literal: true

FactoryBot.define do
  factory :attachment do
    association :attachable, factory: :user

    kind { "photo" }

    url { "https://placehold.co/600x400/000000/FFFFFF?text=Image" }

    trait :logo do
      kind { "logo" }
      url { "https://placehold.co/300x300/CCCCCC/FFFFFF?text=Logo" }
    end

    trait :headshot do
      kind { "headshot" }
      url { "https://placehold.co/200x200/EEEEEE/FFFFFF?text=Headshot" }
    end

    trait :photo do
      kind { "photo" }
      url { "https://placehold.co/200x200/EEEEEE/FFFFFF?text=Photo" }
    end
  end
end
