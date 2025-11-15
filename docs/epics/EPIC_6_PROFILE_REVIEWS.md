🚀 Epic 6: User Profile Management & Reviews

Goal: To allow students to (1) manage their own profile (e.g., update belt rank) and (2) leave reviews (rating + comment) for academies where they have a completed order.

Dependencies: Requires user authentication (Epic 1) and academies (Epic 2). Review creation should ideally require a completed StudentPass (Epic 4/5) for that academy.

📖 User Stories

Student - Update Profile: As a logged-in user, I want to update my profile information (like my first name, last name, and belt rank) so I can keep my details current.

Student - Leave Review: As a logged-in student, I want to leave a rating (1-5) and a text comment for an academy after I have successfully used a pass there.

Public - View Reviews: As any user (public or logged-in), I want to see the list of reviews and average rating for an academy when I view its profile.

📝 Tasks (Sprint Plan)

Story 1: Student - Update Profile

Task 1 (Route): Add PATCH /api/v1/profile route (pointing to profiles#update).

Task 2 (Controller): Create Api::V1::ProfilesController (update action).

Must be protected by authenticate_request!.

Will call current_user.update(profile_params).

Task 3 (Params): Define profile_params to permit firstname, lastname, belt_rank.

Task 4 (Specs): Write controller spec for ProfilesController#update (test success, failure, and that a user cannot update their role).

Story 2: Student - Leave Review

Task 5 (Migration): Create reviews table:

user_id (references users)

academy_id (references academies)

rating (integer, null: false)

comment (text)

Add unique index: [:user_id, :academy_id] (A user can only review an academy once).

Task 6 (Model): Create Review model.

Add associations: belongs_to :user, belongs_to :academy.

Add validations: validates :rating, presence: true, inclusion: { in: 1..5 }.

Add uniqueness validation from the migration.

Task 7 (Model Updates):

User has_many :reviews, dependent: :destroy.

Academy has_many :reviews, dependent: :destroy.

Task 8 (Serializer): Create Api::V1::ReviewSerializer.

Task 9 (Route): Add POST /api/v1/academies/:academy_id/reviews (to reviews#create).

Task 10 (Service): Create Reviews::CreateReview service.

Input: user, academy, review_params.

Validation Logic: Check if the user has any StudentPass for this academy with status: 'expired' or status: 'depleted'. If not, return an error ("You can only review academies you have attended").

Logic: Create the Review.

Task 11 (Controller): Create Api::V1::ReviewsController (create action).

Protected by authenticate_request!.

Loads the Academy.

Calls the Reviews::CreateReview service.

Task 12 (Specs): Write all specs for Review model, ReviewSerializer, CreateReview service, and ReviewsController#create.

Story 3: Public - View Reviews

Task 13 (Route): Add GET /api/v1/academies/:academy_id/reviews (to reviews#index).

Task 14 (Controller): Implement index action in Api::V1::ReviewsController.

Public action (no auth).

Loads academy.reviews.

Renders them using ReviewSerializer.

Task 15 (Serializer Update):

Add has_many :reviews to AcademySerializer (so reviews are embedded in the GET /academies/:id response).

Add average_rating attribute to AcademySerializer.

Task 16 (Model Update): Add average_rating method to Academy model (e.g., reviews.average(:rating).to_f.round(1)).

Task 17 (Specs): Write specs for ReviewsController#index. Update AcademySerializer spec to check for new average_rating and reviews fields.

Story 4: E2E Test

Task 18 (E2E Test): Create spec/requests/api/v1/reviews_spec.rb to test the full flow:

Student (with no pass) tries to review -> Fails.

Student (with a used pass) posts a review -> Succeeds.

Student tries to post a second review -> Fails.

Public user hits GET /academies/:id and sees the new review and updated average rating.