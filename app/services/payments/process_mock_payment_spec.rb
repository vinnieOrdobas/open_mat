# frozen_string_literal: true

RSpec.describe Payments::ProcessMockPayment do
  describe "#perform" do
    let!(:user) { create(:user) }
    let(:order) { create(:order, user: user, status: "pending_approval", total_price_cents: 5000) }
    let(:service) { described_class.new(order: order) }

    context "when the order is pending approval" do
      it "creates one new Payment record" do
        expect { service.perform }.to change(Payment, :count).by(1)
      end

      it "returns a success result with the new payment" do
        result = service.perform
        expect(result[:success]).to be(true)
        expect(result[:payment]).to be_a(Payment)
        expect(result[:errors]).to be_nil
      end

      it "creates a payment record with correct details" do
        result = service.perform
        payment = result[:payment]
        expect(payment.order).to eq(order)
        expect(payment.status).to eq("succeeded")
        expect(payment.amount_cents).to eq(order.total_price_cents)
        expect(payment.currency).to eq(order.currency)
        expect(payment.processor).to eq("mock")
        expect(payment.processor_id).to start_with("mock_ch_")
      end

      it "updates the order's status to 'completed'" do
        service.perform
        expect(order.reload.status).to eq("completed")
      end
    end

    context "when the order is NOT pending approval" do
      before { order.update!(status: "completed") }

      it "does not create a Payment record" do
        expect { service.perform }.not_to change(Payment, :count)
      end

      it "does not change the order status" do
        expect { service.perform }.not_to change { order.reload.status }
      end

      it "returns a failure result with an error message" do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:payment]).to be_nil
        expect(result[:errors]).to include("Order is not pending approval (current status: completed)")
      end
    end

    context "when an operation within the transaction raises RecordInvalid" do
      before do
        order.errors.add(:status, "cannot transition directly to approved")
        allow(order).to receive(:update!).with(status: "approved").and_raise(ActiveRecord::RecordInvalid.new(order))
        allow(order).to receive(:create_payment!)
        allow(order).to receive(:update!).with(status: "completed")
      end

      it "does not create a Payment record" do
        expect { service.perform }.not_to change(Payment, :count)
      end

      it "does not change the order status (due to transaction rollback)" do
        service.perform
        expect(order.reload.status).to eq("pending_approval")
      end

      it "returns a failure result with the order validation errors" do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:payment]).to be_nil
        expect(result[:errors]).not_to be_empty
        expect(result[:errors]).to include("Status cannot transition directly to approved")
      end
    end
  end
end
