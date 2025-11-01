# frozen_string_literal: true

RSpec.describe Orders::CreateOrder do
  describe '#perform' do
    let!(:user) { create(:user) }

    let(:owner_1) { create(:user, :owner) }
    let(:owner_2) { create(:user, :owner) }

    let!(:academy_a) { create(:academy, user: owner_1) }
    let!(:academy_b) { create(:academy, user: owner_2) }

    let!(:pass_a1) { create(:pass, academy: academy_a, price_cents: 2000, currency: 'EUR') }
    let!(:pass_b1) { create(:pass, academy: academy_b, price_cents: 5000, currency: 'USD') }

    context 'with a valid cart from a single academy' do
      let(:cart_items) { [ { pass_id: pass_a1.id, quantity: 2 } ] }
      let(:service) { described_class.new(user: user, cart_items: cart_items) }

      it 'creates one new Order' do
        expect { service.perform }.to change(Order, :count).by(1)
      end

      it 'creates the correct number of OrderLineItems' do
        expect { service.perform }.to change(OrderLineItem, :count).by(1)
      end

      it 'returns a success result with the new order' do
        result = service.perform
        expect(result[:success]).to be(true)
        expect(result[:order]).to be_a(Order)
      end

      it 'sets the order status to "awaiting_approvals"' do
        result = service.perform
        expect(result[:order].status).to eq('awaiting_approvals')
      end

      it 'creates a line item with status "pending_approval"' do
        result = service.perform
        line_item = result[:order].order_line_items.first
        expect(line_item.status).to eq('pending_approval')
      end

      it 'calculates the correct total' do
        result = service.perform
        expect(result[:order].total_price_cents).to eq(4000)
      end
    end

    context 'with a valid cart from different academies' do
      let(:cart_items) do
        [
          { pass_id: pass_a1.id, quantity: 1 },
          { pass_id: pass_b1.id, quantity: 1 }
        ]
      end
      let(:service) { described_class.new(user: user, cart_items: cart_items) }

      it 'creates one new Order' do
        expect { service.perform }.to change(Order, :count).by(1)
      end

      it 'creates two new OrderLineItems' do
        expect { service.perform }.to change(OrderLineItem, :count).by(2)
      end

      it 'returns a success result' do
        result = service.perform
        expect(result[:success]).to be(true)
      end

      it 'sets the order status to "awaiting_approvals"' do
        result = service.perform
        expect(result[:order].status).to eq('awaiting_approvals')
      end

      it 'creates line items with "pending_approval" status' do
        result = service.perform
        expect(result[:order].order_line_items.map(&:status)).to all(eq('pending_approval'))
      end

      it 'calculates the correct total' do
        result = service.perform
        expected_total = pass_a1.price_cents + pass_b1.price_cents
        expect(result[:order].total_price_cents).to eq(expected_total)
      end
    end

    context 'when the cart is empty' do
      let(:cart_items) { [] }
      let(:service) { described_class.new(user: user, cart_items: cart_items) }

      it 'does not create an Order' do
        expect { service.perform }.not_to change(Order, :count)
      end

      it 'returns a failure result with "Cart is empty" error' do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Cart is empty")
      end
    end

    context 'when a pass_id is invalid' do
      let(:cart_items) { [ { pass_id: 'invalid-id', quantity: 1 } ] }
      let(:service) { described_class.new(user: user, cart_items: cart_items) }

      it 'does not create an Order' do
        expect { service.perform }.not_to change(Order, :count)
      end

      it 'returns a failure result with "Pass not found" error' do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Pass with id invalid-id not found")
      end
    end

    context 'when a line item is invalid (e.g., quantity 0)' do
      let(:cart_items) { [ { pass_id: pass_a1.id, quantity: 0 } ] }
      let(:service) { described_class.new(user: user, cart_items: cart_items) }

      it 'does not create an Order (transaction rollback)' do
        expect { service.perform }.not_to change(Order, :count)
      end

      it 'does not create an OrderLineItem (transaction rollback)' do
        expect { service.perform }.not_to change(OrderLineItem, :count)
      end

      it 'returns a failure result with the validation error' do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Validation failed: Quantity must be greater than 0")
      end
    end
  end
end
