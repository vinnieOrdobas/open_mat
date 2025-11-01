🚀 Epic 5: Class Schedules & Booking

Goal: To allow (1) Owners to create and manage their weekly class schedules, and (2) Students to view those schedules and book a spot in a specific class, validating that they have a valid pass.

Dependencies: This epic requires a user to be authenticated (Epic 1), academies to exist (Epic 2), and a student to have a completed order (Epic 4).

📖 User Stories

Owner - Manage Schedule: As a gym owner, I want to add, view, and delete repeating weekly class definitions for my academy (e.g., "Monday 7pm Gi," "Tuesday 6pm No-Gi").

Student - View Schedule: As a student, I want to view the weekly class schedule for a specific academy so I can see what's available.

Student - Book Class: As a logged-in student, I want to book a spot in a specific class. The system must verify that I have a valid, paid-for pass for that academy.

📝 Tasks (Sprint Plan)

Story 1: Owner - Manage Schedule

Task 1 (Migration): Create class_schedules table.

academy_id (references academies, null: false)

title (string, e.g., "All Levels Gi", null: false)

day_of_week (integer, null: false - 0 for Sunday, 1 for Monday, etc.)

start_time (time, null: false)

end_time (time, null: false)

Task 2 (Model): Create ClassSchedule model.

Add associations: belongs_to :academy.

Add validations (e.g., title present, day_of_week between 0-6, end_time after start_time).

Task 3 (Serializer): Create Api::V1::ClassScheduleSerializer.

Task 4 (Routes): Add routes for owners to manage schedules:

POST /api/v1/academies/:academy_id/class_schedules (to class_schedules#create)

DELETE /api/v1/class_schedules/:id (to class_schedules#destroy)

Task 5 (Controller): Create Api::V1::ClassSchedulesController (create, destroy).

Must be protected by authenticate_request!.

Must find the academy and authorize_academy_owner!.

Task 6 (Specs): Write specs for ClassSchedule model, ClassScheduleSerializer, and ClassSchedulesController (create/destroy actions).

Story 2: Student - View Schedule

Task 7 (Route): Add public route to list schedules for an academy:

GET /api/v1/academies/:academy_id/class_schedules (to class_schedules#index)

Task 8 (Controller): Implement index action in Api::V1::ClassSchedulesController.

This action must be public (skip authenticate_request!).

It should find the academy and render all its class_schedules.

Task 9 (Specs): Add specs for the index action to ClassSchedulesController (check for public access, correct list).

Story 3: Student - Book Class

Task 10 (Migration): Create bookings table.

user_id (references users, null: false)

class_schedule_id (references class_schedules, null: false)

Note: For the prototype, we'll book the schedule. A real app might book a specific date.

Task 11 (Model): Create Booking model.

Add associations: belongs_to :user, belongs_to :class_schedule.

Add validation: validates :user_id, uniqueness: { scope: :class_schedule_id, message: "has already booked this class" }.

Task 12 (Serializer): Create Api::V1::BookingSerializer.

Task 13 (Route): Add route for a student to create a booking:

POST /api/v1/class_schedules/:class_schedule_id/bookings (to bookings#create)

Task 14 (Service): Create Bookings::CreateBooking service.

Input: user, class_schedule.

Logic:

Check for double booking.

Validate Pass: Check if this user has any Order that is completed AND contains an OrderLineItem where the pass.academy_id matches the class_schedule.academy_id.

If no valid pass, return error.

If valid pass, create the Booking.

Task 15 (Controller): Create Api::V1::BookingsController (create).

Must be protected by authenticate_request!.

Must load the ClassSchedule.

Calls the Bookings::CreateBooking service.

Task 16 (Specs): Write specs for Booking model, BookingSerializer, Bookings::CreateBooking service, and BookingsController.

Task 17 (E2E Test): Create spec/requests/api/v1/booking_spec.rb to test the full flow:

Owner creates schedule.

Student (with no pass) tries to book -> Fails.

Student (with completed order) tries to book -> Succeeds.

Student tries to book again -> Fails (double booking).