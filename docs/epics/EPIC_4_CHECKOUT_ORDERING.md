🚀 Epic 4 (Revised): Checkout, Approval & Pass Activation

Goal: To allow a student to create an order, an owner to approve the line items, and the student to confirm payment. Upon successful payment, the system activates the purchased passes by creating StudentPass records.

Dependencies: Epics 1, 2, 3.

📖 User Stories

Student - Initiate Checkout: As a student, I want to create an order with passes from multiple academies. The order is awaiting_approvals.

Owner - Manage Order: As an owner, I want to view my pending OrderLineItems and approve or reject them.

Student - Confirm & Activate: As a student, once all my line items are approved, I want to confirm my order, simulate payment, and receive my usable "Student Passes".

Student - View History: As a student, I want to view my Order history.

📝 Tasks (Sprint Plan)

Story 1: Student Initiates Checkout

Task 1 (Migration): Create order_line_items status column (e.g., pending_approval, approved, rejected).

Task 2 (Models): Update Order (status: awaiting_approvals, etc.) & OrderLineItem (add status enum) & Academy (add has_many :order_line_items, through: :passes).

Task 3 (Service): Refactor Orders::CreateOrder service to allow multi-academy carts and create OrderLineItems with pending_approval status.

Task 4 (Controller/Specs): Update OrdersController#create and its specs to align with the refactored service.

(Status: ✅ DONE. We completed these tasks.)

Story 2: Owner Manages Order

Task 5 (Routes):

GET /api/v1/academies/:academy_id/order_line_items (to academy_order_line_items#index)

PATCH /api/v1/order_line_items/:id (to order_line_items#update)

Task 6 (Controller): Create Api::V1::AcademyOrderLineItemsController (index action for owners to list their items).

Task 7 (Service): Create OrderLineItems::UpdateStatus service (logic for approve/reject transitions).

Task 8 (Controller): Create Api::V1::OrderLineItemsController (update action for owners to approve/reject).

Task 9 (Specs): Write all specs for new controllers and service.

(Status: ✅ DONE. We completed these tasks.)

Story 3: Student Confirms & Activates (Pass Activation)

Task 10 (Migration - NEW): Create student_passes table:

user_id (references users)

pass_id (references passes - the "template")

order_line_item_id (references order_line_items - the purchase record)

academy_id (references academies - for easy lookup)

status (string, enum: active, expired, depleted)

expires_at (datetime, null: true - for time-based passes)

credits_remaining (integer, null: true - for credit-based passes)

Task 11 (Model - NEW): Create StudentPass model with associations and status enum.

Task 12 (Factory - NEW): Create student_pass factory.

Task 13 (Serializer - NEW): Create Api::V1::StudentPassSerializer.

Task 14 (Service - NEW): Create Passes::ActivatePasses service.

Input: order_line_item.

Logic: Creates a StudentPass, sets expires_at or credits_remaining based on line_item.pass.pass_type.

Task 15 (Service - REVISED): Refactor Payments::ProcessMockPayment service.

New Logic: Must check that all order.order_line_items are approved.

On success, after creating the Payment, it must loop through each order_line_item and call the Passes::ActivatePasses service for it.

Task 16 (Specs - REVISED): Update specs for ProcessMockPayment and write new specs for ActivatePasses.

Task 17 (Controller): Create Api::V1::OrderConfirmationsController (create action).

Task 18 (Specs): Write specs for OrderConfirmationsController.

Story 4: Student Views Order History

Task 19 (Route): Add GET /api/v1/orders (to orders#index).

Task 20 (Controller): Implement OrdersController#index (fetches current_user.orders).

Task 21 (Specs): Write specs for OrdersController#index.

Story 5: E2E Test

Task 22 (E2E Test): Create spec/requests/api/v1/ordering_spec.rb to test the full, revised flow (Student create -> Owner approve -> Student confirm -> StudentPass is created -> Student views history).