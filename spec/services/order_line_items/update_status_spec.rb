# frozen_string_literal: true

RSpec.describe OrderLineItems::UpdateStatus do
  describe '#perform' do
    let!(:line_item) { create(:order_line_item, status: 'pending_approval') }

    context 'with a valid transition' do
      let(:service) { described_class.new(line_item: line_item, new_status: 'approved') }

      it 'updates the line item status' do
        service.perform
        expect(line_item.reload.status).to eq('approved')
      end

      it 'returns a success result' do
        result = service.perform

        expect(result[:success]).to be(true)
        expect(result[:line_item]).to eq(line_item)
      end
    end

    context 'with an invalid transition (e.g., already approved)' do
      let(:service) { described_class.new(line_item: line_item, new_status: 'rejected') }

      before { line_item.update!(status: 'approved') }

      it 'does not update the status' do
        expect { service.perform }.not_to change { line_item.reload.status }
      end

      it 'returns a failure result with an error' do
        result = service.perform

        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Cannot transition from 'approved' to 'rejected'")
      end
    end

    context 'with an invalid status value' do
      let(:service) { described_class.new(line_item: line_item, new_status: 'paid') } # 'paid' is not a valid enum

      it 'does not update the status' do
        expect { service.perform }.not_to change { line_item.reload.status }
      end

      it 'returns a failure result with an error' do
        result = service.perform

        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("'paid' is not a valid status")
      end
    end
  end
end
