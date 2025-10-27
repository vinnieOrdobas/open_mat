🚀 Epic 4: Checkout & Ordering

Goal: To allow a logged-in student (current_user) to select a Pass from an academy's profile, initiate a checkout process, and complete a simulated purchase. This results in the creation of an Order, OrderLineItem(s), and a mock Payment record.

Dependencies: Requires a logged-in student user (Epic 1) and existing academies with passes (Epics 2 & 3).

📖 User Stories

Initiate Checkout: As a logged-in student, I want to select one or more passes from an academy and initiate a checkout process, creating a pending Order.

Confirm Order (Simulated Payment): As a logged-in student, I want to "confirm" my pending order, which simulates a successful payment and updates the Order and Payment status.

View Order History: As a logged-in student, I want to view a list of my past orders so I can track my purchases.

📝 Tasks (Sprint Plan)

Story 1: Initiate Checkout (Create Pending Order)

Task 1 (Serializers): Create Api::V1::OrderSerializer, Api::V1::OrderLineItemSerializer.

Task 2 (Route): Add POST /api/v1/orders route pointing to Api::V1::OrdersController#create.

Task 3 (Service): Create Orders::CreateOrder service (we sketched this earlier). It must:

Take current_user and cart_items (e.g., [{ pass_id: 1, quantity: 1 }, ...]) as input.

Create a pending Order record.

Create associated OrderLineItem records, capturing price_at_purchase_cents.

Calculate and save the total_price_cents on the Order.

Return a success/failure hash.

Task 4 (Controller): Create Api::V1::OrdersController.

Protect with authenticate_request!.

Implement the create action, calling the Orders::CreateOrder service.

Task 5 (Tests): Write specs for serializers, Orders::CreateOrder service, and OrdersController#create.

Story 2: Confirm Order (Simulated Payment)

Task 6 (Serializer): Create Api::V1::PaymentSerializer.

Task 7 (Route): Add POST /api/v1/orders/:order_id/confirm route pointing to a new Api::V1::OrderConfirmationsController#create (or similar).

Task 8 (Service): Create Payments::ProcessMockPayment service. It must:

Take an Order as input.

Check if the order is pending.

Create a Payment record associated with the order (status: succeeded, processor: 'mock', processor_id: 'mock_#{SecureRandom.hex}').

Update the associated Order status to completed.

Return a success/failure hash.

Task 9 (Controller): Create Api::V1::OrderConfirmationsController.

Protect with authenticate_request!.

Load the Order specified by :order_id.

Authorize that current_user owns the order.

Call the Payments::ProcessMockPayment service.

Task 10 (Tests): Write specs for PaymentSerializer, Payments::ProcessMockPayment service, and OrderConfirmationsController#create.

Story 3: View Order History

Task 11 (Route): Add GET /api/v1/orders route pointing back to Api::V1::OrdersController#index.

Task 12 (Controller Action): Implement the index action in Api::V1::OrdersController.

Protect with authenticate_request!.

Fetch only the current_user's orders (current_user.orders).

Render the orders using OrderSerializer.

Task 13 (Tests): Write specs for OrdersController#index.

Task 14 (E2E Test): Write a request spec (spec/requests/api/v1/ordering_spec.rb) covering the full flow: create order -> confirm order -> view order history.