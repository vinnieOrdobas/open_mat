# frozen_string_literal: true

RSpec.describe ClassSchedules::CreateSchedule do
  describe '#perform' do
    let(:owner) { create(:user, :owner) }
    let!(:academy) { create(:academy, user: owner) }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          title: 'Morning Open Mat',
          day_of_week: 2,
          start_time: '09:00:00',
          end_time: '10:30:00'
        }
      end
      let(:service) { described_class.new(academy: academy, params: valid_params) }

      it 'creates a new ClassSchedule' do
        expect { service.perform }.to change(ClassSchedule, :count).by(1)
      end

      it 'assigns the schedule to the correct academy' do
        result = service.perform
        expect(result[:schedule].academy).to eq(academy)
      end

      it 'returns a success result with the new schedule' do
        result = service.perform
        expect(result[:success]).to be(true)
        expect(result[:schedule]).to be_a(ClassSchedule)
        expect(result[:schedule].title).to eq('Morning Open Mat')
        expect(result[:errors]).to be_nil
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          title: 'Bad Time Class',
          day_of_week: 1,
          start_time: '19:00:00',
          end_time: '18:00:00'
        }
      end
      let(:service) { described_class.new(academy: academy, params: invalid_params) }

      it 'does not create a new ClassSchedule' do
        expect { service.perform }.not_to change(ClassSchedule, :count)
      end

      it 'returns a failure result with validation errors' do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:schedule]).to be_nil
        expect(result[:errors]).to include("End time must be after start time")
      end
    end
  end
end
