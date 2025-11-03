# frozen_string_literal: true

RSpec.describe ClassScheduleSerializer, type: :serializer do
  let(:start_time) { Time.zone.parse('19:00:00') }
  let(:end_time) { Time.zone.parse('20:30:00') }
  let!(:class_schedule) do
    build_stubbed(
      :class_schedule,
      id: 1,
      title: 'Monday Gi Class',
      day_of_week: 1,
      start_time: start_time,
      end_time: end_time,
      created_at: Time.current,
      updated_at: Time.current
    )
  end

  let(:json) { described_class.new(class_schedule).as_json.deep_symbolize_keys }

  let(:expected_keys) do
    %i[id academy_id title day_of_week start_time end_time created_at updated_at]
  end

  it 'includes all the expected attributes' do
    expect(json.keys).to contain_exactly(*expected_keys)
  end

  it 'returns the correct values' do
    expect(json[:id]).to eq(class_schedule.id)
    expect(json[:title]).to eq('Monday Gi Class')
    expect(json[:day_of_week]).to eq(1)
  end

  it 'returns the correct time values (formatted as HH:MM strings)' do
    expect(json[:start_time]).to eq('19:00')
    expect(json[:end_time]).to eq('20:30')
  end

  it 'formats the timestamps using ApplicationSerializer' do
    expect(json[:created_at]).to eq(class_schedule.created_at.iso8601)
    expect(json[:updated_at]).to eq(class_schedule.updated_at.iso8601)
  end
end
