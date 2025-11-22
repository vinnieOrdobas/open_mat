
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

amenities = {
  showers: Amenity.find_or_create_by!(name: "Showers", category: "facilities"),
  wifi: Amenity.find_or_create_by!(name: "Free WiFi", category: "convenience"),
  mats: Amenity.find_or_create_by!(name: "Premium Mats", category: "facilities"),
  gi_rental: Amenity.find_or_create_by!(name: "Gi Rentals", category: "equipment"),
  ac: Amenity.find_or_create_by!(name: "Air Conditioning", category: "facilities"),
  sauna: Amenity.find_or_create_by!(name: "Sauna", category: "facilities"),
  parking: Amenity.find_or_create_by!(name: "Free Parking", category: "convenience")
}

puts "Created #{Amenity.count} amenities."

academy_a = Academy.find_or_create_by!(name: "Alliance BJJ Dublin") do |a|
  a.user = owner_a
  a.email = "info@alliancedublin.com"
  a.street_address = "123 Fake St"
  a.city = "Dublin"
  a.country = "Ireland"
  a.description = "World-class BJJ in the heart of Dublin. All levels welcome."
  a.latitude = 53.3498
  a.longitude = -6.2603
end

academy_b = Academy.find_or_create_by!(name: "Gracie Barra Cork") do |a|
  a.user = owner_b
  a.email = "info@gbcork.com"
  a.street_address = "456 Main St"
  a.city = "Cork"
  a.country = "Ireland"
  a.description = "Jiu-Jitsu for everyone. Family-friendly environment."
  a.latitude = 51.8985
  a.longitude = -8.4756
end

academy_c = Academy.find_or_create_by!(name: "Roger Gracie Academy HQ") do |a|
  a.user = owner_b
  a.email = "hq@rogergracie.com"
  a.street_address = "10 Ladbroke Grove"
  a.city = "London"
  a.country = "United Kingdom"
  a.description = "Train at the world famous HQ of 10x World Champion Roger Gracie."
  a.latitude = 51.5074
  a.longitude = -0.1278
end

academy_d = Academy.find_or_create_by!(name: "Renzo Gracie NYC") do |a|
  a.user = owner_b
  a.email = "info@renzogracie.com"
  a.street_address = "224 W 30th St"
  a.city = "New York"
  a.country = "United States"
  a.description = "The blue basement. Legendary training in the heart of Manhattan."
  a.latitude = 40.7128
  a.longitude = -74.0060
end

academy_e = Academy.find_or_create_by!(name: "Checkmat Copacabana") do |a|
  a.user = owner_b
  a.email = "rio@checkmat.com"
  a.street_address = "Av. Atlântica"
  a.city = "Rio de Janeiro"
  a.country = "Brazil"
  a.description = "Train by the beach in the birthplace of BJJ."
  a.latitude = -22.9068
  a.longitude = -43.1729
end

academy_f = Academy.find_or_create_by!(name: "Carpe Diem Aoyama") do |a|
  a.user = owner_b
  a.email = "aoyama@carpediem.jp"
  a.street_address = "Minato City"
  a.city = "Tokyo"
  a.country = "Japan"
  a.description = "Modern, stylish BJJ in the heart of Tokyo. Visitors welcome."
  a.latitude = 35.6895
  a.longitude = 139.6917
end

puts "Created #{Academy.count} academies."

[ amenities[:showers], amenities[:mats], amenities[:wifi] ].each { |a| AcademyAmenity.find_or_create_by!(academy: academy_a, amenity: a) }
[ amenities[:showers], amenities[:gi_rental] ].each { |a| AcademyAmenity.find_or_create_by!(academy: academy_b, amenity: a) }
[ amenities[:showers], amenities[:sauna], amenities[:ac] ].each { |a| AcademyAmenity.find_or_create_by!(academy: academy_c, amenity: a) }
[ amenities[:showers], amenities[:mats], amenities[:ac], amenities[:wifi] ].each { |a| AcademyAmenity.find_or_create_by!(academy: academy_d, amenity: a) }
[ amenities[:gi_rental], amenities[:showers] ].each { |a| AcademyAmenity.find_or_create_by!(academy: academy_e, amenity: a) }
[ amenities[:showers], amenities[:ac], amenities[:wifi] ].each { |a| AcademyAmenity.find_or_create_by!(academy: academy_f, amenity: a) }

Pass.find_or_create_by!(academy: academy_a, name: "Single Day Pass") { |p| p.price_cents = 2000; p.pass_type = "day_pass" }
Pass.find_or_create_by!(academy: academy_a, name: "10-Class Punch Card") { |p| p.price_cents = 15000; p.pass_type = "punch_card"; p.class_credits = 10 }
Pass.find_or_create_by!(academy: academy_b, name: "1 Week Unlimited") { |p| p.price_cents = 6000; p.pass_type = "week_pass" }
Pass.find_or_create_by!(academy: academy_c, name: "Day Pass") { |p| p.price_cents = 3000; p.pass_type = "day_pass" }
Pass.find_or_create_by!(academy: academy_c, name: "Week Unlimited") { |p| p.price_cents = 10000; p.pass_type = "week_pass" }
Pass.find_or_create_by!(academy: academy_d, name: "Drop-in") { |p| p.price_cents = 4000; p.pass_type = "single" }
Pass.find_or_create_by!(academy: academy_d, name: "Month Unlimited") { |p| p.price_cents = 25000; p.pass_type = "month_pass" }
Pass.find_or_create_by!(academy: academy_e, name: "Day Pass") { |p| p.price_cents = 1000; p.pass_type = "day_pass" }
Pass.find_or_create_by!(academy: academy_f, name: "Visitor Pass") { |p| p.price_cents = 3500; p.pass_type = "day_pass" }

puts "Created #{Pass.count} passes."

ClassSchedule.find_or_create_by!(academy: academy_a, day_of_week: 1, start_time: "19:00") { |cs| cs.title = "All Levels Gi"; cs.end_time = "20:30" } # Save reference for booking
schedule_a_1 = ClassSchedule.find_by(academy: academy_a, day_of_week: 1, start_time: "19:00")

ClassSchedule.find_or_create_by!(academy: academy_a, day_of_week: 2, start_time: "18:00") { |cs| cs.title = "Fundamentals"; cs.end_time = "19:00" }
ClassSchedule.find_or_create_by!(academy: academy_b, day_of_week: 1, start_time: "18:30") { |cs| cs.title = "No-Gi Class"; cs.end_time = "20:00" }
ClassSchedule.find_or_create_by!(academy: academy_c, day_of_week: 5, start_time: "12:00") { |cs| cs.title = "Black Belt Class"; cs.end_time = "13:30" }
ClassSchedule.find_or_create_by!(academy: academy_d, day_of_week: 3, start_time: "12:00") { |cs| cs.title = "No-Gi Pro Training"; cs.end_time = "14:00" }
ClassSchedule.find_or_create_by!(academy: academy_e, day_of_week: 6, start_time: "10:00") { |cs| cs.title = "Sparring"; cs.end_time = "12:00" }
ClassSchedule.find_or_create_by!(academy: academy_f, day_of_week: 4, start_time: "19:00") { |cs| cs.title = "Evening Gi"; cs.end_time = "20:30" }

puts "Created #{ClassSchedule.count} class schedules."
puts "Seeding attachments..."

all_academies = [ academy_a, academy_b, academy_c, academy_d, academy_e, academy_f ]
Attachment.where(attachable: all_academies).destroy_all
puts "Cleared old attachments."

LOGO_FILE = "logo.png"
PHOTO_1_FILE = "photo_1.png"
PHOTO_2_FILE = "photo_2.png"

all_academies.each do |academy|
  Attachment.create!(
    attachable: academy,
    kind: 'logo',
    url: "/seed_images/#{LOGO_FILE}"
  )
  Attachment.create!(
    attachable: academy,
    kind: 'photo',
    url: "/seed_images/#{PHOTO_1_FILE}"
  )
  Attachment.create!(
    attachable: academy,
    kind: 'photo',
    url: "/seed_images/#{PHOTO_2_FILE}"
  )
end

puts "Created #{Attachment.count} attachments."

if student.orders.empty?
  puts "Seeding student history..."

  pass_a_day = academy_a.passes.find_by(name: "Single Day Pass")
  pass_b_week = academy_b.passes.find_by(name: "1 Week Unlimited")

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
    status: 'active',
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
