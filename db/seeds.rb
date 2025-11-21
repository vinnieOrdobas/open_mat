# This file populates the database with initial data for development and production demos.
# It is designed to be run multiple times without creating duplicates.

puts "Seeding database..."

student = User.find_or_create_by!(email: "student@example.com") do |u|
  u.username = "student"
  u.firstname = "BJJ"
  u.lastname = "Student"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = "student"
  u.belt_rank = "blue"
end

owner_a = User.find_or_create_by!(email: "owner-a@example.com") do |u|
  u.username = "owner_a"
  u.firstname = "Academy"
  u.lastname = "Owner A"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = "owner"
end

owner_b = User.find_or_create_by!(email: "owner-b@example.com") do |u|
  u.username = "owner_b"
  u.firstname = "Academy"
  u.lastname = "Owner B"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = "owner"
end

puts "Created #{User.count} users."

# --- 2. Create Master Amenities ---
amenity_showers = Amenity.find_or_create_by!(name: "Showers", category: "facilities")
amenity_gi = Amenity.find_or_create_by!(name: "Gi Rentals", category: "equipment")
amenity_mats = Amenity.find_or_create_by!(name: "Large Mat Area", category: "facilities")
amenity_wifi = Amenity.find_or_create_by!(name: "Free WiFi", category: "convenience")

puts "Created #{Amenity.count} amenities."

academy_a = Academy.find_or_create_by!(name: "Alliance BJJ Dublin") do |a|
  a.user = owner_a
  a.email = "info@alliancedublin.com"
  a.street_address = "123 Fake St"
  a.city = "Dublin"
  a.country = "IE"
  a.description = "World-class BJJ in the heart of Dublin. All levels welcome."
end

academy_b = Academy.find_or_create_by!(name: "Gracie Barra Cork") do |a|
  a.user = owner_b
  a.email = "info@gbcork.com"
  a.street_address = "456 Main St"
  a.city = "Cork"
  a.country = "IE"
  a.description = "Jiu-Jitsu for everyone. Family-friendly environment."
end

puts "Created #{Academy.count} academies."

# --- 4. Link Amenities to Academies ---
AcademyAmenity.find_or_create_by!(academy: academy_a, amenity: amenity_showers)
AcademyAmenity.find_or_create_by!(academy: academy_a, amenity: amenity_mats)
AcademyAmenity.find_or_create_by!(academy: academy_a, amenity: amenity_wifi)
AcademyAmenity.find_or_create_by!(academy: academy_b, amenity: amenity_showers)
AcademyAmenity.find_or_create_by!(academy: academy_b, amenity: amenity_gi)

# --- 5. Create Passes for Academies ---
pass_a_day = Pass.find_or_create_by!(academy: academy_a, name: "Single Day Pass") do |p|
  p.price_cents = 2000
  p.pass_type = "day_pass"
end

pass_a_10 = Pass.find_or_create_by!(academy: academy_a, name: "10-Class Punch Card") do |p|
  p.price_cents = 15000
  p.pass_type = "punch_card"
  p.class_credits = 10
end

pass_b_week = Pass.find_or_create_by!(academy: academy_b, name: "1 Week Unlimited") do |p|
  p.price_cents = 6000
  p.pass_type = "week_pass"
end

puts "Created #{Pass.count} passes."

# --- 6. Create Class Schedules ---
ClassSchedule.find_or_create_by!(academy: academy_a, day_of_week: 1, start_time: "19:00") do |cs|
  cs.title = "All Levels Gi"
  cs.end_time = "20:30"
end
ClassSchedule.find_or_create_by!(academy: academy_a, day_of_week: 2, start_time: "18:00") do |cs|
  cs.title = "Fundamentals"
  cs.end_time = "19:00"
end
ClassSchedule.find_or_create_by!(academy: academy_b, day_of_week: 1, start_time: "18:30") do |cs|
  cs.title = "No-Gi Class"
  cs.end_time = "20:00"
end

puts "Created #{ClassSchedule.count} class schedules."

puts "Seeding attachments..."

Attachment.where(attachable: [ academy_a, academy_b ]).destroy_all
puts "Cleared old attachments."

LOGO_FILE = "logo.png"
PHOTO_1_FILE = "photo_1.png"
PHOTO_2_FILE = "photo_2.png"

Attachment.create!(
  attachable: academy_a,
  kind: 'logo',
  url: "/seed_images/#{LOGO_FILE}"
)
Attachment.create!(
  attachable: academy_a,
  kind: 'photo',
  url: "/seed_images/#{PHOTO_1_FILE}"
)
Attachment.create!(
  attachable: academy_a,
  kind: 'photo',
  url: "/seed_images/#{PHOTO_2_FILE}"
)

Attachment.create!(
  attachable: academy_b,
  kind: 'logo',
  url: "/seed_images/#{LOGO_FILE}"
)
Attachment.create!(
  attachable: academy_b,
  kind: 'photo',
  url: "/seed_images/#{PHOTO_1_FILE}"
)
Attachment.create!(
  attachable: academy_b,
  kind: 'photo',
  url: "/seed_images/#{PHOTO_2_FILE}"
)

puts "Created #{Attachment.count} attachments."

if student.orders.empty?
  puts "Seeding student history..."

  order = Order.create!(
    user: student,
    status: 'completed',
    total_price_cents: (pass_a_day.price_cents + pass_b_week.price_cents),
    currency: 'USD'
  )

  item_a = OrderLineItem.create!(
    order: order,
    pass: pass_a_day,
    quantity: 1,
    price_at_purchase_cents: pass_a_day.price_cents,
    status: 'approved'
  )

  student_pass_a = StudentPass.create!(
    user: student,
    pass: pass_a_day,
    order_line_item: item_a,
    academy: academy_a,
    status: 'active', # It was active...
    credits_remaining: 1
  )

  item_b = OrderLineItem.create!(
    order: order,
    pass: pass_b_week,
    quantity: 1,
    price_at_purchase_cents: pass_b_week.price_cents,
    status: 'approved'
  )
  StudentPass.create!(
    user: student,
    pass: pass_b_week,
    order_line_item: item_b,
    academy: academy_b,
    status: 'active',
    expires_at: 1.week.from_now
  )

  Payment.create!(
    order: order,
    status: 'succeeded',
    amount_cents: order.total_price_cents,
    currency: 'USD',
    processor: 'mock',
    processor_id: 'seed_pay_12345'
  )

  Booking.create!(
    user: student,
    class_schedule: schedule_a_1,
    student_pass: student_pass_a
  )

  student_pass_a.update!(credits_remaining: 0, status: 'depleted')

  puts "Created history: 1 Order, 2 Passes, 1 Booking."
else
  puts "Student history already exists."
end

puts "Seed data created successfully!"
