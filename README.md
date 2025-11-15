# OpenMat API

<!-- Placeholder badge -->

**OpenMat** is the complete backend API for a "ClassPass-style" booking platform, built specifically for
the Brazilian Jiu-Jitsu (BJJ) community.

This API provides a fully-featured, secure, and scalable foundation for a platform that allows:
**Students** to discover gyms, buy passes, book classes, and leave reviews.
**Academy Owners** to manage their public profiles, schedules, passes, and orders.
The backend is 100% complete and verified by a comprehensive test suite. The next step is to build the
frontend client application.

## ✨ Core Features

The API is built on a service-oriented architecture and includes the following complete features:

**User Authentication & Profiles:**
- Secure user registration (POST /api/v1/users).
- JWT-based authentication (POST /api/v1/login).
- Protected profile management (GET / PATCH /api/v1/profile).
- Role-based distinction (student vs. owner).

**Public Academy Browsing:**
- Public endpoint to list all academies (GET /api/v1/academies).
- Advanced filtering by city, country, and amenities.
- Public endpoint to view a single academy's full profile (GET /api/v1/academies/:id), including nested amenities, passes, and reviews.

**Owner-Side Management:**
- Full CRUD (Create/Update) for an owner's Academy profiles.
- Full CRUD (Create/Delete) for an academy's Pass offerings (e.g., "10-Class Card").
- Full CRUD (Create/Delete) for an academy's ClassSchedule.
- Full CRUD (Add/Remove) for an academy's Amenities.

**Multi-Step Order & Booking Flow:**

- **Student:** Can create a single Order with passes from _multiple_ academies.
- **Owner:** Can view their OrderLineItems and approve or reject them.
- **Student:** Can "pay" for a fully-approved order (via a mock payment endpoint).
- **System:** Automatically generates StudentPass records (a "digital wallet") upon payment, with correct expiration dates or credits.
- **Student:** Can book a class, which validates and "redeems" a pass from their wallet.
- **Reviews & Ratings:**


```
Students can only review academies they have attended (i.e., have a used StudentPass for).
Owners cannot review.
Full create, update, and destroy actions for a user's own reviews.
Public endpoint to list all reviews for an academy (GET /api/v1/academies/:id/reviews).
The main academy profile (GET /api/v1/academies/:id) automatically includes all reviews
and a calculated average_rating.
```
## 🛠 Tech Stack

```
Backend: Ruby on Rails 7 (API-only)
Database: PostgreSQL
Testing: RSpec, FactoryBot, Shoulda-Matchers, Timecop
Authentication: bcrypt and jwt (JSON Web Tokens)
Architecture: Service-Oriented (thin controllers, "command" objects in app/services, "query"
objects in app/queries)
```
## 🚀 Getting Started

To get the API server running locally:

**1. Prerequisites**
- Ruby (see .ruby-version)
- Bundler (gem install bundler)
- PostgreSQL (running locally)

**2. Installation & Setup**

```
# 1. Clone the repository
git clone [https://github.com/YOUR_USERNAME/open_mat.git](https://github.com/YOUR_USERN
cd open_mat
# 2. Install dependencies
bundle install
# 3. Create and set up the database
rails db:create
rails db:migrate
```
**3. Running the Server**

```
# Start the Rails server
rails s
```
The API will be available at [http://localhost:3000.](http://localhost:3000.)


**4. Running the Test Suite**
This project is 100% covered by a robust test suite.

```
# Run all RSpec specs
bundle exec rspec
```
## 📖 API Documentation

The complete documentation for all V1 endpoints, including request/response examples, is located in
the /docs directory.

**View the Complete API Documentation**

## 🌎 Deployment Plan

```
Backend (This Repo): Deployed to Render.
Frontend (React App): Deployed to Vercel.
```
## ➡ Next Steps

The backend API is complete. The next phase of this project is to build the React frontend application
that will consume this API.


