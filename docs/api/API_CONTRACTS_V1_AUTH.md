API Contracts (V1) - Authentication

This document defines the API contract for all endpoints related to user authentication and management.

1. User Registration

Registers a new user in the system.

Endpoint: POST /api/v1/users

Authentication: None required.

Request Body

{
"user": {
"firstname": "Test",
"lastname": "User",
"email": "test@example.com",
"username": "testuser",
"password": "password123",
"password_confirmation": "password123"
}
}


Success Response (Status: 201 Created)

Returns the newly created user object, as defined by UserSerializer.

{
"id": 1,
"username": "testuser",
"email": "test@example.com",
"firstname": "Test",
"lastname": "User",
"role": "student",
"belt_rank": null,
"created_at": "2025-10-26T20:30:00.000Z",
"updated_at": "2025-10-26T20:30:00.000Z"
}


Failure Response (Status: 422 Unprocessable Entity)

Returns an error object if validations fail.

{
"errors": [
"Email can't be blank",
"Password confirmation doesn't match Password"
]
}


2. User Login

Authenticates a user and returns a JSON Web Token (JWT).

Endpoint: POST /api/v1/login

Authentication: None required.

Request Body

{
"session": {
"email": "test@example.com",
"password": "password123"
}
}


Success Response (Status: 200 OK)

Returns the JWT and its expiration timestamp (as a Unix integer).

{
"token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3NjY5MTQ0MTd9.abc123xyz",
"exp": 1766914417
}


Failure Response (Status: 401 Unauthorized)

Returns an error if the email or password is
incorrect.

{
"error": "Invalid email or password"
}


3. View Profile

Fetches the profile for the currently authenticated user.

Endpoint: GET /api/v1/profile

Authentication: Required. The request must include a valid JWT in the Authorization header.

Authentication Header

Authorization: Bearer <your_jwt_token_here>


Request Body

None.

Success Response (Status: 200 OK)

Returns the authenticated user object, as defined by UserSerializer.

{
"id": 1,
"username": "testuser",
"email": "test@example.com",
"firstname": "Test",
"lastname": "User",
"role": "student",
"belt_rank": null,
"created_at": "2025-10-26T20:30:00.000Z",
"updated_at": "2025-10-26T20:30:00.000Z"
}


Failure Response (Status: 401 Unauthorized)

Returns an error if the token is missing, invalid, or expired.

{
"error": "Not Authorized"
}