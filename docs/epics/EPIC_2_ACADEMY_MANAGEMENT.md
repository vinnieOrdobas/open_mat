🚀 Epic 2: Academy Management (For Owners)

Goal: To allow a user with the role: 'owner' to create, update, and manage their BJJ academy profile. This includes managing profile details, amenities, and the passes they offer for sale.

Dependencies: This epic requires a user to be authenticated (Epic 1). All endpoints will be protected by authenticate_request!.

📖 User Stories

Academy Creation: As a gym owner (current_user), I want to create a new academy profile with its name, address, and description, so I can list my gym on the platform.

Academy Management: As a gym owner, I want to view and update the details of an academy I own, so I can keep my profile information accurate.

Amenity Management: As a gym owner, I want to browse a list of available amenities and add or remove them from my academy's profile (e.g., "Showers," "Gi Rentals").

Pass Management: As a gym owner, I want to create, update, and manage the different Passes (e.g., "Day Pass," "10-Class Card") that my academy sells.

📝 Tasks (Sprint Plan)

This is the planned breakdown of work for this epic.

Story 1: Academy Creation

Task 1 (Serializer): Create Api::V1::AcademySerializer.

Task 2 (Route): Add POST /api/v1/academies route to Api::V1::AcademiesController#create.

Task 3 (Service): Create Academies::CreateAcademy service. It must:

Take current_user and academy_params as input.

Build the academy associated with the current_user.

Return a success/failure hash ({ success: true, academy: ... }).

Task 4 (Controller): Create Api::V1::AcademiesController.

It must inherit from Api::V1::ApplicationController.

It must use before_action :authenticate_request!.

The create action must authorize that current_user.owner? is true.

It must call the Academies::CreateAcademy service.

Task 5 (Tests): Write specs for AcademySerializer, Academies::CreateAcademy, and Api::V1::AcademiesController#create.

Story 2: Academy Management (View/Update)

Task 6 (Authorization): Implement authorization logic (e.g., a simple private method in AcademiesController) to ensure only the owner (@academy.user == current_user) can perform show, update, or destroy actions.

Task 7 (Routes): Add GET /api/v1/academies/:id and PATCH /api/v1/academies/:id to Api::V1::AcademiesController#show and #update.

Task 8 (Service): Create Academies::UpdateAcademy service.

Task 9 (Controller): Implement show and update actions in Api::V1::AcademiesController. Both must be protected by the authorization logic from Task 6.

Task 10 (Tests): Write specs for Academies::UpdateAcademy and the show/update controller actions, including "happy path" (owner) and "sad path" (non-owner).

Story 3: Amenity Management

Task 11 (Serializer): Create Api::V1::AmenitySerializer.

Task 12 (Route + Controller): Create Api::V1::AmenitiesController with an index action. This provides the master list of all amenities for the UI (GET /api/v1/amenities).

Task 13 (Routes): Add nested routes for managing academy-specific amenities:

POST /api/v1/academies/:academy_id/amenities (to AcademyAmenitiesController#create)

DELETE /api/v1/academies/:academy_id/amenities/:id (to AcademyAmenitiesController#destroy)

Task 14 (Controller): Create Api::V1::AcademyAmenitiesController.

It must be protected by authenticate_request!.

It must authorize that the current_user owns the specified academy_id.

Task 15 (Tests): Write specs for AmenitySerializer and AcademyAmenitiesController.

Story 4: Pass Management

Task 16 (Serializer): Create Api::V1::PassSerializer.

Task 17 (Routes): Add routes for pass management:

POST /api/v1/academies/:academy_id/passes (to Api::V1::PassesController#create)

PATCH /api/v1/passes/:id (to Api::V1::PassesController#update)

DELETE /api/v1/passes/:id (to Api::V1::PassesController#destroy)

Task 18 (Controller): Create Api::V1::PassesController.

Must be protected by authenticate_request!.

Must authorize that the current_user owns the associated academy for all actions.

Task 19 (Services): Create services (Passes::CreatePass, Passes::UpdatePass) as needed.

Task 20 (Tests): Write specs for PassSerializer and PassesController.