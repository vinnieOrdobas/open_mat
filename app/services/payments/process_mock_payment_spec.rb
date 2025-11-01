# frozen_string_literal: true

RSpec.describe Payments::ProcessMockPayment do
  describe "#perform" do
    let!(:user) { create(:user) }
    let!(:owner) { create(:user, :owner) }
    let!(:academy) { create(:academy, user: owner) }
    let(:order) { create(:order, user: user, status: "awaiting_approvals") }
    let!(:pass) { create(:pass, academy: academy) }
    let(:service) { described_class.new(order: order) }

    context "when order is 'awaiting_approvals' and all line items are 'approved'" do
      let!(:line_item) { create(:order_line_item, order: order, pass: pass, status: "approved") }

      it "creates one new Payment record" do
        expect { service.perform }.to change(Payment, :count).by(1)
      end

      it "returns a success result with the new payment" do
        result = service.perform
        expect(result[:success]).to be(true)
        expect(result[:payment]).to be_a(Payment)
      end

      it "updates the order's status to 'completed'" do
        service.perform
        expect(order.reload.status).to eq("completed")
      end

      it "creates a payment with correct details" do
        result = service.perform
        expect(result[:payment].status).to eq("succeeded")
        expect(result[:payment].amount_cents).to eq(order.total_price_cents)
      end
    end

    context "when the order status is not 'awaiting_approvals'" do
       before { order.update!(status: "completed") }

      let!(:line_item) { create(:order_line_item, order: order, pass: pass, status: "approved") }

      it "does not create a Payment record" do
        expect { service.perform }.not_to change(Payment, :count)
      end

      it "returns a failure result with an error message" do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Order is not awaiting approvals (status: completed)")
      end
    end

    context "when one or more line items are still 'pending_approval'" do
      let!(:line_item) { create(:order_line_item, order: order, pass: pass, status: "pending_approval") }

      it "does not create a Payment record" do
        expect { service.perform }.not_to change(Payment, :count)
      end

      it "returns a failure result with an error message" do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Not all line items have been approved")
      end
    end

    context "when one or more line items are 'rejected'" do
      let!(:another_pass) { create(:pass, academy: academy) }
      let!(:other_pass) { create(:pass, academy: academy) }
      let!(:line_item_approved) { create(:order_line_item, order: order, pass: another_pass, status: "approved") }
      let!(:line_item_rejected) { create(:order_line_item, order: order, pass: other_pass, status: "rejected") }

      it "does not create a Payment record" do
        expect { service.perform }.not_to change(Payment, :count)
      end

      it "returns a failure result with an error message" do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Not all line items have been approved")
      end
    end
  end
end
