# frozen_string_literal: true

RSpec.describe Orders::CreateOrder do
  describe '#perform' do
    let!(:user) { create(:user) }
    let!(:owner) { create(:user, :owner) }
    let!(:academy) { create(:academy, user: owner) }
    let!(:pass1) { create(:pass, academy: academy, name: 'Day Pass', price_cents: 2000, currency: 'EUR') }
    let!(:pass2) { create(:pass, academy: academy, name: 'Week Pass', price_cents: 8000, currency: 'EUR') }

    context 'with valid cart items' do
      let(:cart_items) do
        [
          { pass_id: pass1.id, quantity: 1 },
          { pass_id: pass2.id, quantity: 2 }
        ]
      end
      let(:service) { described_class.new(user: user, cart_items: cart_items) }

      it 'creates one new Order' do
        expect { service.perform }.to change(Order, :count).by(1)
      end

      it 'creates the correct number of OrderLineItems' do
        expect { service.perform }.to change(OrderLineItem, :count).by(2)
      end

      it 'returns a success result with the new order' do
        result = service.perform
        expect(result[:success]).to be(true)
        expect(result[:order]).to be_an(Order)
        expect(result[:errors]).to be_nil
      end

      it 'assigns the order to the correct user and sets initial status' do
        result = service.perform
        order = result[:order]
        expect(order.user).to eq(user)
        expect(order.status).to eq('pending_approval')
      end

      it 'creates line items with correct associations and captured prices' do
        result = service.perform
        order = result[:order]
        line_item1 = order.order_line_items.find { |li| li.pass_id == pass1.id }
        line_item2 = order.order_line_items.find { |li| li.pass_id == pass2.id }

        expect(line_item1).not_to be_nil
        expect(line_item1.quantity).to eq(1)
        expect(line_item1.price_at_purchase_cents).to eq(2000)

        expect(line_item2).not_to be_nil
        expect(line_item2.quantity).to eq(2)
        expect(line_item2.price_at_purchase_cents).to eq(8000)
      end

      it 'calculates and saves the correct total price and currency on the order' do
        result = service.perform
        order = result[:order]
        expected_total = (1 * 2000) + (2 * 8000)
        expect(order.total_price_cents).to eq(expected_total)
        expect(order.currency).to eq('EUR')
      end
    end

    context 'with invalid cart items (e.g., non-existent pass_id)' do
      let(:invalid_cart_items) do
        [
          { pass_id: pass1.id, quantity: 1 },
          { pass_id: 'invalid-id', quantity: 1 }
        ]
      end
      let(:service) { described_class.new(user: user, cart_items: invalid_cart_items) }

      it 'does not create an Order' do
        expect { service.perform }.not_to change(Order, :count)
      end

      it 'does not create any OrderLineItems' do
        expect { service.perform }.not_to change(OrderLineItem, :count)
      end

      it 'returns a failure result with a RecordNotFound error message' do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:order]).to be_nil
        expect(result[:errors]).to include("Couldn't find Pass with 'id'=\"invalid-id\"")
      end
    end

    context 'with invalid quantity (e.g., zero)' do
      let(:invalid_quantity_items) do
        [
          { pass_id: pass1.id, quantity: 0 }
        ]
      end
      let(:service) { described_class.new(user: user, cart_items: invalid_quantity_items) }

      it 'does not create an Order or LineItems' do
        expect { service.perform }.not_to change(Order, :count)
        expect { service.perform }.not_to change(OrderLineItem, :count)
      end

      it 'returns a failure result with validation error' do
        result = service.perform
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Validation failed: Quantity must be greater than 0")
      end
    end
  end
end
