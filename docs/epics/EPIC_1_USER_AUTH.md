🚀 Epic 1: User Authentication & Management

Goal: To allow a user to create a new account, log in to the application securely, and manage their session. This epic establishes the current_user, which is the foundation for all other modules.

📖 User Stories

Registration: As a new user, I want to sign up with my email, username, and password so that I can create an account on OpenMat.

Login: As a returning user, I want to log in with my email and password so that I can receive an auth token to access my account.

Authentication: As a logged-in user, I want to send my auth token with requests so that the system can identify who I am.

Profile View: As a logged-in user, I want to fetch my own profile information so that I can confirm my identity and role.

✅ Tasks Completed (Definition of Done)

This epic is complete. The following tasks were successfully built, tested, and verified.

Story 1: Registration

Task 1 (Serializer): Created ApplicationSerializer base class and UserSerializer to expose a safe, public view of the User model (explicitly excluding password_digest).

Task 2 (Route): Added POST /api/v1/users route pointing to Api::V1::UsersController#create.

Task 3 (Service + Controller):

Created Users::RegisterUser service to handle registration business logic.

Created Api::V1::UsersController to handle the request, call the service, and render the JSON response.

Task 4 (Tests): Wrote unit tests for UserSerializer, Users::RegisterUser, and Api::V1::UsersController.

Story 2: Login

Task 5 (JWT Setup): Added jwt gem. Created lib/json_web_token.rb module to handle encoding and decoding tokens. Wrote unit tests.

Task 6 (Route): Added POST /api/v1/login route pointing to Api::V1::SessionsController#create.

Task 7 (Service + Controller):

Created Sessions::AuthenticateUser service to handle login business logic.

Created Api::V1::SessionsController to handle the request, call the service, and issue a JWT.

Task 8 (Tests): Wrote unit tests for Sessions::AuthenticateUser and Api::V1::SessionsController.

Story 3: Authentication

Task 9 (Application Controller): Implemented current_user and authenticate_request! helper methods in Api::V1::ApplicationController to act as a "gatekeeper" for protected endpoints.

Task 10 (Tests): Wrote unit tests for Api::V1::ApplicationController using a dummy controller to verify the gatekeeper logic.

Story 4: Profile View

Task 11 (Route): Added GET /api/v1/profile route pointing to Api::V1::ProfileController#show.

Task 12 (Controller): Created Api::V1::ProfileController that uses the authenticate_request! before_action to protect the endpoint and render the @current_user.

Task 13 (Tests): Wrote unit tests for Api::V1::ProfileController.

Epic Verification

Task 14 (E2E Test): Wrote a full end-to-end request spec (spec/requests/api/v1/authentication_spec.rb) to verify the entire user flow (register -> login -> access protected route) works perfectly.