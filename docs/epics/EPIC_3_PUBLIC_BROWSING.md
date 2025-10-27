🚀 Epic 3: Public Academy Browsing

Goal: To allow any user (logged in or not) to browse a list of BJJ academies, search/filter them, and view the public profile of a specific academy, including its amenities and available passes.

Dependencies: Requires academies and passes to exist in the database (Epic 2).

📖 User Stories

List Academies: As a potential student, I want to see a list of all available BJJ academies so that I can discover places to train.

Search/Filter Academies: As a potential student, I want to filter the list of academies (e.g., by city, country, or amenities) so that I can find gyms relevant to me.

View Academy Profile: As a potential student, I want to view the detailed profile of a specific academy, including its description, address, amenities, and the passes it offers, so I can decide if I want to train there.

📝 Tasks (Sprint Plan)

Story 1: List Academies (Basic Index)

Task 1 (Route): Add GET /api/v1/academies route pointing to Api::V1::AcademiesController#index.

Task 2 (Controller Action): Implement the index action in Api::V1::AcademiesController.

It should not require authentication.

It should fetch all academies (or a paginated list).

It should render the academies using the AcademySerializer.

Task 3 (Tests): Write request specs for the index action.

Story 2: Search/Filter Academies

Task 4 (Query Object): Create Academies::SearchQuery service (as discussed previously). It should include methods for filtering by city, country, and potentially amenity_id.

Task 5 (Controller Update): Update the AcademiesController#index action to use the SearchQuery service, passing in query parameters from params.

Task 6 (Tests): Update the request specs for the index action to include tests for filtering.

Story 3: View Academy Profile (Including Associations)

Task 7 (Serializer Updates):

Update AcademySerializer to include has_many :amenities and has_many :passes associations.

Ensure AmenitySerializer and PassSerializer are correctly defined.

Task 8 (Controller Update): Modify the Api::V1::AcademiesController#show action:

Make it public (remove the authorize_academy_owner! before_action for this specific action).

Ensure it renders the academy using the updated AcademySerializer (which will now include amenities and passes).

Task 9 (Tests): Update the request specs for the show action to verify that amenities and passes are included in the response and that non-owners can now access it.