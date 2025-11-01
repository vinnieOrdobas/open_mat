🚀 Epic 5 (Revised): Class Schedules & Booking

Goal: To allow owners to manage their class schedules and students to book a spot, redeeming their StudentPass in the process.

Dependencies: Requires a student to have an active StudentPass (created in Epic 4).

📖 User Stories

Owner - Manage Schedule: (Same as before)

Student - View Schedule: (Same as before)

Student - Book Class: (Revised) As a logged-in student, I want to book a class by redeeming an active, valid StudentPass from my "wallet".

📝 Tasks (Sprint Plan)

Story 1: Owner - Manage Schedule

Task 1 (Migration): Create class_schedules table (academy_id, title, day_of_week, start_time, end_time).

Task 2 (Model): Create ClassSchedule model with associations & validations.

Task 3 (Serializer): Create Api::V1::ClassScheduleSerializer.

Task 4 (Routes):

POST /api/v1/academies/:academy_id/class_schedules

DELETE /api/v1/class_schedules/:id

Task 5 (Controller): Create Api::V1::ClassSchedulesController (create, destroy) with owner authorization.

Task 6 (Specs): Write all specs.

Story 2: Student - View Schedule

Task 7 (Route): GET /api/v1/academies/:academy_id/class_schedules

Task 8 (Controller): Implement index action in ClassSchedulesController (public).

Task 9 (Specs): Write specs for index action.

Story 3: Student - Book Class (Revised Logic)

Task 10 (Migration): Create bookings table.

user_id (references users)

class_schedule_id (references class_schedules)

student_pass_id (references student_passes - NEW: tracks which pass was used)

Task 11 (Model): Create Booking model.

Add associations: belongs_to :user, belongs_to :class_schedule, belongs_to :student_pass.

Add validations (e.g., uniqueness: { scope: ... }).

Task 12 (Serializer): Create Api::V1::BookingSerializer.

Task 13 (Route): POST /api/v1/class_schedules/:class_schedule_id/bookings

Task 14 (Service - REVISED): Create Bookings::CreateBooking service.

Input: user, class_schedule.

New Logic:

Find a valid StudentPass for this user & academy (StudentPass.find_by(user: user, academy_id: class_schedule.academy_id, status: 'active')).

If no pass, return error: "No active pass found."

Check pass validity:

If time-based (expires_at), check if expires_at > Time.current.

If credit-based (credits_remaining), check if credits_remaining > 0.

If invalid (expired/depleted), set status to expired/depleted and return error.

Redeem (in a transaction):

Create the Booking, linking it to the student_pass.id.

If credit-based, student_pass.decrement!(:credits_remaining).

If credits_remaining == 0, set status = 'depleted'.

If it was a single pass, set status = 'depleted'.

Task 15 (Controller): Create Api::V1::BookingsController (create).

Task 16 (Specs): Write all specs for the new/revised logic.

Task 17 (E2E Test): Create spec/requests/api/v1/booking_spec.rb to test the full, correct booking flow.