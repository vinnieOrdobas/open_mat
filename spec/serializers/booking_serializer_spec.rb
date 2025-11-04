# frozen_string_literal: true

RSpec.describe BookingSerializer, type: :serializer do
  let!(:class_schedule) { build_stubbed(:class_schedule, title: 'Monday Gi') }
  let!(:student_pass) { build_stubbed(:student_pass, :credit_based, credits_remaining: 9) }

  let!(:booking) do
    build_stubbed(
      :booking,
      id: 1,
      class_schedule: class_schedule,
      student_pass: student_pass,
      created_at: Time.current
    )
  end

  let(:json) { described_class.new(booking).as_json.deep_symbolize_keys }

  let(:expected_keys) { %i[id user_id created_at class_schedule student_pass] }

  it 'includes all the expected attributes and associations' do
    expect(json.keys).to contain_exactly(*expected_keys)
  end

  it 'returns the correct top-level values' do
    expect(json[:id]).to eq(booking.id)
    expect(json[:user_id]).to eq(booking.user_id)
  end

  it 'includes the nested class_schedule data' do
    expect(json[:class_schedule]).to be_a(Hash)
    expect(json[:class_schedule][:title]).to eq('Monday Gi')
    expect(json[:class_schedule][:day_of_week]).to eq(1)
  end

  it 'includes the nested student_pass data' do
    expect(json[:student_pass]).to be_a(Hash)
    expect(json[:student_pass][:status]).to eq('active')
    expect(json[:student_pass][:credits_remaining]).to eq(9)
  end
end
