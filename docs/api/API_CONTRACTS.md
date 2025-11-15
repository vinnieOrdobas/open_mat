# **OpenMat API Documentation (V1)**

This document defines the complete API contract for the V1 backend. All endpoints are prefixed with /api/v1.

## **1\. Authentication & Profile**

Endpoints for user registration, login, and profile management.

### **1.1 User Registration**

Registers a new user (default role: student).

* **Endpoint:** POST /users  
* **Protection:** None (Public)  
* **Request Body:**  
  ````
  {  
    "user": {  
      "firstname": "Test",  
      "lastname": "User",  
      "email": "test@example.com",  
      "username": "testuser",  ****
      "password": "password123",  
      "password\_confirmation": "password123"  
    }  
  }


* **Success Response:** 201 Created \- UserSerializer  
* **Failure Response:** 422 Unprocessable Entity

### **1.2 User Login**

Authenticates a user and returns a JSON Web Token (JWT).

* **Endpoint:** POST /login  
* **Protection:** None (Public)  
* **Request Body:**  
````
  {  
    "session": {  
      "email": "test@example.com",  
      "password": "password123"  
    }  
  }
  ````
* **Success Response:** 200 OK
````
  {  
    "token": "eyJhbGciOiJIUzI1NiJ9...",  
    "exp": 1766914417  
  }
````
* **Failure Response:** 401 Unauthorized

### **1.3 View Profile (Self)**

Fetches the profile for the *currently authenticated* user.

* **Endpoint:** GET /profile  
* **Protection:** Authenticated User  
* **Success Response:** 200 OK \- UserSerializer

### **1.4 Update Profile (Self)**

Updates the profile for the *currently authenticated* user.

* **Endpoint:** PATCH /profile  
* **Protection:** Authenticated User  
* **Request Body:** (Only permitted attributes will be updated)  
````
  {  
    "user": {  
      "firstname": "Updated",  
      "lastname": "Name",  
      "belt\_rank": "blue"  
    }  
  }
````
* **Success Response:** 200 OK \- UserSerializer  
* **Failure Response:** 422 Unprocessable Entity

## **2\. Academies**

Endpoints for listing, viewing, creating, and managing academies.

### **2.1 List Academies (Public)**

Returns a list of all academies. Supports filtering.

* **Endpoint:** GET /academies  
* **Protection:** None (Public)  
* **Query Params (Optional):**  
  * city (string): Filters by city (partial match).  
  * country (string): Filters by country code.  
  * amenity\_id (integer): Filters by academies that have this amenity.  
* **Success Response:** 200 OK \- \[AcademySerializer, ...\]

### **2.2 View Academy Profile (Public)**

Returns the full public profile for a single academy, including its amenities, passes, and reviews.

* **Endpoint:** GET /academies/:id  
* **Protection:** None (Public)  
* **Success Response:** 200 OK \- AcademySerializer (with nested amenities, passes, reviews, and average\_rating).

### **2.3 Create Academy (Owner)**

Creates a new academy profile.

* **Endpoint:** POST /academies  
* **Protection:** Authenticated owner  
* **Request Body:**  
```
  {  
    "academy": {  
      "name": "My New BJJ Gym",  
      "email": "info@mynewgym.com",  
      "street\_address": "123 Main St",  
      "city": "My City",  
      "country": "US"  
    }  
  }
```
* **Success Response:** 201 Created \- AcademySerializer  
* **Failure Response:** 401 Unauthorized, 422 Unprocessable Entity

### **2.4 Update Academy (Owner)**

Updates an existing academy profile.

* **Endpoint:** PATCH /academies/:id  
* **Protection:** Authenticated owner (must own this academy)  
* **Request Body:**  
```
  {  
    "academy": {  
      "name": "Updated Gym Name",  
      "phone_number": "555-1234"  
    }  
  }
```
* **Success Response:** 200 OK \- AcademySerializer  
* **Failure Response:** 401 Unauthorized, 404 Not Found, 422 Unprocessable Entity

## **3\. Amenities**

Endpoints for listing and managing academy amenities.

### **3.1 List All Amenities (Public)**

Returns the master list of all amenities the platform supports.

* **Endpoint:** GET /amenities  
* **Protection:** None (Public)  
* **Success Response:** 200 OK \- \[AmenitySerializer, ...\]

### **3.2 Add Amenity to Academy (Owner)**

* **Endpoint:** POST /academies/:academy\_id/amenities  
* **Protection:** Authenticated owner (must own this academy)  
* **Request Body:**  
```
  {  
    "academy_amenity": {  
      "amenity_id": 5  
    }  
  }
```
* **Success Response:** 201 Created \- { "id": 123 } (ID of the join record)  
* **Failure Response:** 401 Unauthorized, 404 Not Found, 422 Unprocessable Entity

### **3.3 Remove Amenity from Academy (Owner)**

* **Endpoint:** DELETE /academies/:academy\_id/amenities/:id (Note: :id is the amenity\_id)  
* **Protection:** Authenticated owner (must own this academy)  
* **Success Response:** 204 No Content  
* **Failure Response:** 401 Unauthorized, 404 Not Found

## **4\. Passes (Owner Management)**

Endpoints for owners to manage the passes their academy sells.

### **4.1 Create Pass for Academy**

* **Endpoint:** POST /academies/:academy\_id/passes  
* **Protection:** Authenticated owner (must own this academy)  
* **Request Body:**  
```
  {  
    "pass": {  
      "name": "1 Week Unlimited",  
      "price_cents": 6000,  
      "pass_type": "week_pass"  
    }  
  }
```
* **Success Response:** 201 Created \- PassSerializer

### **4.2 Update Pass**

* **Endpoint:** PATCH /academies/:academy\_id/passes/:id  
* **Protection:** Authenticated owner (must own this academy)  
* **Request Body:**
```
  {  
    "pass": {  
      "price_cents": 6500,  
      "is_active": false  
    }  
  }
```
* **Success Response:** 200 OK \- PassSerializer

### **4.3 Delete Pass**

* **Endpoint:** DELETE /academies/:academy\_id/passes/:id  
* **Protection:** Authenticated owner (must own this academy)  
* **Success Response:** 204 No Content

## **5\. Ordering & Checkout**

Endpoints for the student purchase flow and owner approval.

### **5.1 Create Order (Student)**

Initiates a new order with a list of items.

* **Endpoint:** POST /orders  
* **Protection:** Authenticated User  
* **Request Body:**
```
  {  
    "order": {  
      "cart_items": [  
        { "pass_id": 1, "quantity": 1 }  
      ]  
    }
  }
```
* **Success Response:** 201 Created \- OrderSerializer (with nested order\_line\_items)

### **5.2 List Line Items for Academy (Owner)**

Returns a list of all line items for an owner's academy.

* **Endpoint:** GET /academies/:academy\_id/order\_line\_items  
* **Protection:** Authenticated owner (must own this academy)  
* **Query Params (Optional):**  
  * status=pending_approval  
* **Success Response:** 200 OK - [OrderLineItemSerializer, ...]

### **5.3 Approve/Reject Line Item (Owner)**

Allows an owner to update the status of a specific line item.

* **Endpoint:** PATCH /order\_line\_items/:id  
* **Protection:** Authenticated owner (must own the academy associated with this item)  
* **Request Body:**
```
  {  
    "order_line_item": {  
      "status": "approved"  
    }  
  }
```

* **Success Response:** 200 OK \- OrderLineItemSerializer  
* **Failure Response:** 401 Unauthorized, 404 Not Found, 422 Unprocessable Entity

### **5.4 Confirm & "Pay" for Order (Student)**

Triggers the mock payment process and creates StudentPass records.

* **Endpoint:** POST /orders/:order\_id/confirmation  
* **Protection:** Authenticated User (must own this order)  
* **Success Response:** 201 Created \- PaymentSerializer  
* **Failure Response:** 422 Unprocessable Entity (e.g., "Not all line items have been approved")

### **5.5 View Order History (Student)**

Returns a list of all orders for the authenticated student.

* **Endpoint:** GET /orders  
* **Protection:** Authenticated User  
* **Success Response:** 200 OK - [OrderSerializer, ...]

## **6\. Class Schedules & Bookings**

Endpoints for managing class timetables and student bookings.

### **6.1 List Class Schedules (Public)**

Returns the weekly schedule for a specific academy.

* **Endpoint:** GET /academies/:academy\_id/class\_schedules  
* **Protection:** None (Public)  
* **Success Response:** 200 OK \- \[ClassScheduleSerializer, ...\]

### **6.2 Create Class Schedule (Owner)**

* **Endpoint:** POST /academies/:academy\_id/class\_schedules  
* **Protection:** Authenticated owner (must own this academy)  
* **Request Body:**  
```
  {  
    "class_schedule": {  
      "title": "All Levels Gi",  
      "day_of_week": 1,  
      "start_time": "19:00",  
      "end_time": "20:30"  
    }  
  }
```
* **Success Response:** 201 Created - ClassScheduleSerializer

### **6.3 Delete Class Schedule (Owner)**

* **Endpoint:** DELETE /academies/:academy\_id/class\_schedules/:id  
* **Protection:** Authenticated owner (must own this academy)  
* **Success Response:** 204 No Content

### **6.4 Create Booking (Student)**

Books the authenticated user for a class, "redeeming" an active StudentPass.

* **Endpoint:** POST /academies/:academy_id/class_schedules/:class_schedule_id/bookings  
* **Protection:** Authenticated User  
* **Request Body:** (None)  
* **Success Response:** 201 Created - BookingSerializer  
* **Failure Response:** 422 Unprocessable Entity (e.g., "No active pass found...")

## **7\. Reviews**

Endpoints for creating and viewing academy reviews.

### **7.1 List Reviews (Public)**

Returns all reviews for a specific academy.

* **Endpoint:** GET /academies/:academy_id/reviews  
* **Protection:** None (Public)  
* **Success Response:** 200 OK - [ReviewSerializer, ...]

### **7.2 Create Review (Student)**

Creates a new review for an academy. *User must have a used (depleted or expired) StudentPass for this academy.*

* **Endpoint:** POST /academies/:academy\_id/reviews  
* **Protection:** Authenticated User  
* **Request Body:**
```
  {  
    "review": {  
      "rating": 5,  
      "comment": "Great atmosphere\!"  
    }  
  }
```
* **Success Response:** 201 Created- ReviewSerializer  
* **Failure Response:** 422 Unprocessable Entity

### **7.3 Update Review (Author)**

Updates a review written by the authenticated user.

* **Endpoint:** PATCH /academies/:academy_id/reviews/:id  
* **Protection:** Authenticated User (must be the review's author)  
* **Request Body:**  
```
  {  
    "review": {  
      "rating": 4,  
      "comment": "Still great."  
    }  
  }
```
* **Success Response:** 200 OK \- ReviewSerializer  
* **Failure Response:** 401 Unauthorized, 404 Not Found

### **7.4 Delete Review (Author)**

Deletes a review written by the authenticated user.

* **Endpoint:** DELETE /academies/:academy_id/reviews/:id  
* **Protection:** Authenticated User (must be the review's author)  
* **Success Response:** 204 No Content  
* **Failure Response:** 401 Unauthorized, 404 Not Found