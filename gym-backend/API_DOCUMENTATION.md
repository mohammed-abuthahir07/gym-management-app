# Gym Management System API Documentation

Base URL: `http://localhost:5000`  
Port: `process.env.PORT` or `5000`

No query parameters are used in the current implementation.

JWT payload fields: `id`, `email`, `role`  
JWT expiry: `process.env.JWT_EXPIRES_IN` or `7d`

## Common Auth Middleware Errors

These can occur on any API that uses `authMiddleware`.

error = 401

{
    "success": false,
    "message": "Authorization token is required"
}

error = 401

{
    "success": false,
    "message": "Invalid authorization format"
}

error = 401

{
    "success": false,
    "message": "Token is required"
}

error = 401

{
    "success": false,
    "message": "Invalid or expired token"
}

## Common Role Middleware Errors

These can occur on any API that uses `roleMiddleware`.

error = 401

{
    "success": false,
    "message": "Authentication required"
}

error = 403

{
    "success": false,
    "message": "Access denied"
}

error = 500

{
    "success": false,
    "message": "Server error during authorization"
}

## API Summary

| # | Method | API | Role | Auth |
|---|---|---|---|---|
| 1 | POST | /api/contact | PUBLIC | No |
| 2 | POST | /api/member/auth/register | MEMBER | No |
| 3 | POST | /api/member/auth/login | MEMBER | No |
| 4 | GET | /api/member/auth/profile | MEMBER | JWT |
| 5 | GET | /api/member/exercises | MEMBER | JWT |
| 6 | GET | /api/member/challenges | MEMBER | JWT |
| 7 | POST | /api/member/progress | MEMBER | JWT |
| 8 | GET | /api/member/progress | MEMBER | JWT |
| 9 | GET | /api/member/progress/:id | MEMBER | JWT |
| 10 | PUT | /api/member/progress/:id | MEMBER | JWT |
| 11 | DELETE | /api/member/progress/:id | MEMBER | JWT |
| 12 | POST | /api/member/profile | MEMBER | JWT |
| 13 | GET | /api/member/profile | MEMBER | JWT |
| 14 | PUT | /api/member/profile | MEMBER | JWT |
| 15 | GET | /api/member/notifications | MEMBER | JWT |
| 16 | PUT | /api/member/notifications/:id/read | MEMBER | JWT |
| 17 | GET | /api/member/class-schedules | MEMBER | JWT |
| 18 | GET | /api/member/class-schedules/:id | MEMBER | JWT |
| 19 | GET | /api/member/workout-plans | MEMBER | JWT |
| 20 | GET | /api/member/workout-plans/:id | MEMBER | JWT |
| 21 | POST | /api/member/workout-plans/:planId/exercises/:workoutExerciseId/complete | MEMBER | JWT |
| 22 | GET | /api/member/diet-plans | MEMBER | JWT |
| 23 | GET | /api/member/diet-plans/:id | MEMBER | JWT |
| 24 | GET | /api/member/diet-plans/today | MEMBER | JWT |
| 25 | GET | /api/member/messages/trainer | MEMBER | JWT |
| 26 | GET | /api/member/messages/:trainerId | MEMBER | JWT |
| 27 | POST | /api/member/messages/:trainerId | MEMBER | JWT |
| 28 | PUT | /api/member/messages/:id/read | MEMBER | JWT |
| 29 | GET | /api/member/dashboard/checkin-days | MEMBER | JWT |
| 30 | GET | /api/member/dashboard/cheat-count | MEMBER | JWT |
| 31 | GET | /api/member/dashboard/diet-plan | MEMBER | JWT |
| 32 | GET | /api/member/dashboard/workout-plans | MEMBER | JWT |
| 33 | GET | /api/member/dashboard/notifications | MEMBER | JWT |
| 34 | GET | /api/member/dashboard/previous-month-progress | MEMBER | JWT |
| 35 | GET | /api/member/dashboard/today-workout | MEMBER | JWT |
| 36 | POST | /api/member/cheat-days | MEMBER | JWT |
| 37 | GET | /api/member/cheat-days | MEMBER | JWT |
| 38 | GET | /api/member/cheat-days/:id | MEMBER | JWT |
| 39 | PUT | /api/member/cheat-days/:id | MEMBER | JWT |
| 40 | DELETE | /api/member/cheat-days/:id | MEMBER | JWT |
| 41 | POST | /api/trainer/auth/login | TRAINER | No |
| 42 | GET | /api/trainer/auth/profile | TRAINER | JWT |
| 43 | GET | /api/trainer/assigned-members | TRAINER | JWT |
| 44 | GET | /api/trainer/assigned-members/:id | TRAINER | JWT |
| 45 | POST | /api/trainer/class-schedules | TRAINER | JWT |
| 46 | GET | /api/trainer/class-schedules | TRAINER | JWT |
| 47 | GET | /api/trainer/class-schedules/:id | TRAINER | JWT |
| 48 | PUT | /api/trainer/class-schedules/:id | TRAINER | JWT |
| 49 | DELETE | /api/trainer/class-schedules/:id | TRAINER | JWT |
| 50 | POST | /api/trainer/workout-plans | TRAINER | JWT |
| 51 | GET | /api/trainer/workout-plans | TRAINER | JWT |
| 52 | GET | /api/trainer/workout-plans/:id | TRAINER | JWT |
| 53 | PUT | /api/trainer/workout-plans/:id | TRAINER | JWT |
| 54 | DELETE | /api/trainer/workout-plans/:id | TRAINER | JWT |
| 55 | POST | /api/trainer/workout-plans/:id/exercises | TRAINER | JWT |
| 56 | PUT | /api/trainer/workout-plans/:planId/exercises/:workoutExerciseId | TRAINER | JWT |
| 57 | DELETE | /api/trainer/workout-plans/:planId/exercises/:workoutExerciseId | TRAINER | JWT |
| 58 | POST | /api/trainer/diet-plans | TRAINER | JWT |
| 59 | GET | /api/trainer/diet-plans | TRAINER | JWT |
| 60 | GET | /api/trainer/diet-plans/:id | TRAINER | JWT |
| 61 | PUT | /api/trainer/diet-plans/:id | TRAINER | JWT |
| 62 | DELETE | /api/trainer/diet-plans/:id | TRAINER | JWT |
| 63 | GET | /api/trainer/messages | TRAINER | JWT |
| 64 | GET | /api/trainer/messages/:memberId | TRAINER | JWT |
| 65 | POST | /api/trainer/messages/:memberId | TRAINER | JWT |
| 66 | PUT | /api/trainer/messages/:id/read | TRAINER | JWT |
| 67 | GET | /api/trainer/dashboard/assigned-members | TRAINER | JWT |
| 68 | GET | /api/trainer/dashboard/diet-plans | TRAINER | JWT |
| 69 | GET | /api/trainer/dashboard/workout-plans | TRAINER | JWT |
| 70 | GET | /api/trainer/dashboard/check-ins | TRAINER | JWT |
| 71 | GET | /api/trainer/cheat-days/members | TRAINER | JWT |
| 72 | GET | /api/trainer/cheat-days/current-month | TRAINER | JWT |
| 73 | GET | /api/trainer/cheat-days/previous-month | TRAINER | JWT |
| 74 | GET | /api/trainer/cheat-days/members/:memberId | TRAINER | JWT |
| 75 | GET | /api/trainer/cheat-days/members/:memberId/:id | TRAINER | JWT |
| 76 | POST | /api/admin/auth/login | ADMIN | No |
| 77 | GET | /api/admin/auth/profile | ADMIN | JWT |
| 78 | POST | /api/admin/trainers | ADMIN | JWT |
| 79 | GET | /api/admin/trainers | ADMIN | JWT |
| 80 | GET | /api/admin/trainers/:id | ADMIN | JWT |
| 81 | DELETE | /api/admin/trainers/:id | ADMIN | JWT |
| 82 | GET | /api/admin/members | ADMIN | JWT |
| 83 | GET | /api/admin/members/:id | ADMIN | JWT |
| 84 | DELETE | /api/admin/members/:id | ADMIN | JWT |
| 85 | PUT | /api/admin/members/:id/trainer | ADMIN | JWT |
| 86 | DELETE | /api/admin/members/:id/trainer | ADMIN | JWT |
| 87 | POST | /api/admin/plans | ADMIN | JWT |
| 88 | GET | /api/admin/plans | ADMIN | JWT |
| 89 | GET | /api/admin/plans/:id | ADMIN | JWT |
| 90 | POST | /api/admin/promotions | ADMIN | JWT |
| 91 | GET | /api/admin/promotions | ADMIN | JWT |
| 92 | GET | /api/admin/promotions/:id | ADMIN | JWT |
| 93 | PUT | /api/admin/promotions/:id | ADMIN | JWT |
| 94 | DELETE | /api/admin/promotions/:id | ADMIN | JWT |
| 95 | POST | /api/admin/challenges | ADMIN | JWT |
| 96 | GET | /api/admin/challenges | ADMIN | JWT |
| 97 | GET | /api/admin/challenges/:id | ADMIN | JWT |
| 98 | PUT | /api/admin/challenges/:id | ADMIN | JWT |
| 99 | DELETE | /api/admin/challenges/:id | ADMIN | JWT |
| 100 | POST | /api/admin/notifications/members | ADMIN | JWT |
| 101 | POST | /api/admin/notifications/trainers | ADMIN | JWT |
| 102 | POST | /api/admin/notifications/member/:id | ADMIN | JWT |
| 103 | POST | /api/admin/notifications/trainer/:id | ADMIN | JWT |
| 104 | GET | /api/admin/notifications | ADMIN | JWT |
| 105 | POST | /api/admin/exercises | ADMIN | JWT |
| 106 | GET | /api/admin/exercises | ADMIN | JWT |
| 107 | GET | /api/admin/exercises/:id | ADMIN | JWT |
| 108 | PUT | /api/admin/exercises/:id | ADMIN | JWT |
| 109 | DELETE | /api/admin/exercises/:id | ADMIN | JWT |
| 110 | GET | /api/admin/contacts | ADMIN | JWT |
| 111 | GET | /api/admin/contacts/:id | ADMIN | JWT |
| 112 | DELETE | /api/admin/contacts/:id | ADMIN | JWT |
| 113 | GET | /api/admin/dashboard/member | ADMIN | JWT |
| 114 | GET | /api/admin/dashboard/trainer | ADMIN | JWT |
| 115 | GET | /api/admin/dashboard/plan | ADMIN | JWT |
| 116 | GET | /api/admin/dashboard/promotion | ADMIN | JWT |
| 117 | GET | /api/admin/dashboard/challenge | ADMIN | JWT |
| 118 | GET | /api/admin/dashboard/recent/plan | ADMIN | JWT |
| 119 | GET | /api/admin/dashboard/recent/promotion | ADMIN | JWT |
| 120 | GET | /api/admin/dashboard/recent/challenge | ADMIN | JWT |
| 121 | POST | /api/admin/content | ADMIN | JWT |
| 122 | GET | /api/admin/content | ADMIN | JWT |
| 123 | GET | /api/admin/content/:id | ADMIN | JWT |
| 124 | PUT | /api/admin/content/:id | ADMIN | JWT |
| 125 | DELETE | /api/admin/content/:id | ADMIN | JWT |
| 126 | GET | /api/admin/analytics/member | ADMIN | JWT |
| 127 | GET | /api/admin/analytics/trainer | ADMIN | JWT |
| 128 | GET | /api/admin/analytics/plan | ADMIN | JWT |
| 129 | GET | /api/admin/analytics/promotion | ADMIN | JWT |
| 130 | GET | /api/admin/analytics/challenge | ADMIN | JWT |
/api/admin/dashboard/current-month-revenue
GET /api/admin/dashboard/current-year-revenue
GET http://localhost:5000/api/admin/dashboard/total-revenue
GET /api/admin/report/current-month-revenue
GET /api/admin/report/current-year-revenue
GET /api/admin/report/total-revenue
GET /api/admin/report/current-month-checkins
GET /api/admin/report/current-year-checkins
GET /api/admin/report/current-month-unpaid
POST /api/admin/fees => request = {
    "member_id": 4,
    "member_name": "Mohammed Abuthahir",
    "member_email": "mohammed@gmail.com",
    "fitness_goal": "Build muscle",
    "fee_amount": 1500,
    "fee_date": "2026-09-09",
    "fee_month": "SEPTEMBER",
    "fee_year": 2026,
    "payment_status": "PAID"
}
GET /api/admin/fees
GET /api/admin/fees/member/:memberId
GET /api/admin/fees/member/:ID
PUT /api/admin/fees/:id
DELETE /api/admin/fees/:id
GET /api/admin/fees/current-month
GET /api/member/fees
GET /api/member/fees/:id
GET /api/member/fees/current-month/paid-status
GET /api/member/fees/paid-history
GET /api/trainer/analytics/today-workouts
GET /api/member/analytics/current-month-payment-status
GET /api/member/analytics/tomorrow-workout
GET /api/member/analytics/current-month-cheat-meals
GET /api/member/analytics/current-month-progress
GET http://localhost:5000/api/trainers
GET http://localhost:5000/api/content
GET http://localhost:5000/api/promotions
GET http://localhost:5000/api/plans

# Public APIs

<!-- Contact -->
POST /api/contact

auth = None

request = {
    "name": "Mohammed",
    "email": "mohammed@gmail.com",
    "phone": "9876543210",
    "message": "I want to know about gym membership plans"
}

response = {
    "success": true,
    "message": "Enquiry sent successfully",
    "data": {
        "id": 1
    }
}

error = 400

{
    "success": false,
    "message": "Name, email and message are required"
}

error = 500

{
    "success": false,
    "message": "Failed to send enquiry"
}

# Authentication APIs

<!-- Member -->
POST /api/member/auth/register

auth = None

request = {
    "name": "Mohammed",
    "email": "mohammed@gmail.com",
    "phone": "9876543210",
    "fitness_goal": "Build muscle and improve overall fitness",
    "password": "Member@123"
}

response = {
    "success": true,
    "message": "Member registered successfully",
    "memberId": 1
}

error = 400

{
    "success": false,
    "message": "Name, email and password are required"
}

error = 409

{
    "success": false,
    "message": "Member with this email already exists"
}

error = 500

{
    "success": false,
    "message": "Server error during member registration"
}

<!-- Member -->
POST /api/member/auth/login

auth = None

request = {
    "email": "mohammed@gmail.com",
    "password": "Member@123"
}

response = {
    "success": true,
    "message": "Member login successful",
    "token": "JWT_TOKEN_HERE",
    "user": {
        "id": 1,
        "name": "Mohammed",
        "email": "mohammed@gmail.com",
        "role": "MEMBER",
        "phone": "9876543210",
        "fitness_goal": "Build muscle and improve overall fitness",
        "status": "ACTIVE"
    }
}

error = 400

{
    "success": false,
    "message": "Email and password are required"
}

error = 401

{
    "success": false,
    "message": "Invalid email or password"
}

error = 403

{
    "success": false,
    "message": "Member account is inactive"
}

error = 500

{
    "success": false,
    "message": "Server error during member login"
}

<!-- Member -->
GET /api/member/auth/profile

auth = Bearer JWT

access = Own member data only. Role is not checked in the current implementation.

request = None

response = {
    "success": true,
    "message": "Member profile fetched successfully",
    "member": {
        "id": 1,
        "name": "Mohammed",
        "email": "mohammed@gmail.com",
        "role": "MEMBER",
        "phone": "9876543210",
        "fitness_goal": "Build muscle and improve overall fitness",
        "status": "ACTIVE",
        "created_at": "2026-01-10T08:00:00.000Z",
        "updated_at": "2026-01-10T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Member not found"
}

error = 500

{
    "success": false,
    "message": "Server error while fetching member profile"
}

<!-- Trainer -->
POST /api/trainer/auth/login

auth = None

request = {
    "email": "ahmed@gmail.com",
    "password": "Trainer@123"
}

response = {
    "success": true,
    "message": "Trainer login successful",
    "token": "JWT_TOKEN_HERE",
    "trainer": {
        "id": 2,
        "name": "Ahmed",
        "email": "ahmed@gmail.com",
        "role": "TRAINER",
        "phone": "9123456780",
        "status": "ACTIVE"
    }
}

error = 400

{
    "success": false,
    "message": "Email and password are required"
}

error = 401

{
    "success": false,
    "message": "Invalid email or password"
}

error = 403

{
    "success": false,
    "message": "Trainer account is inactive"
}

error = 500

{
    "success": false,
    "message": "Server error during trainer login"
}

<!-- Trainer -->
GET /api/trainer/auth/profile

auth = Bearer JWT

role = TRAINER

access = Own trainer data only

request = None

response = {
    "success": true,
    "message": "Trainer profile fetched successfully",
    "trainer": {
        "id": 2,
        "name": "Ahmed",
        "email": "ahmed@gmail.com",
        "role": "TRAINER",
        "phone": "9123456780",
        "status": "ACTIVE",
        "created_at": "2026-01-05T08:00:00.000Z",
        "updated_at": "2026-01-05T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Trainer not found"
}

error = 500

{
    "success": false,
    "message": "Server error while fetching trainer profile"
}

<!-- Admin -->
POST /api/admin/auth/login

auth = None

request = {
    "email": "admin@gmail.com",
    "password": "Admin@123"
}

response = {
    "success": true,
    "message": "Admin login successful",
    "token": "JWT_TOKEN_HERE",
    "admin": {
        "id": 1,
        "name": "Admin",
        "email": "admin@gmail.com",
        "role": "ADMIN",
        "phone": "9000000000",
        "status": "ACTIVE"
    }
}

error = 400

{
    "success": false,
    "message": "Email and password are required"
}

error = 401

{
    "success": false,
    "message": "Invalid email or password"
}

error = 403

{
    "success": false,
    "message": "Admin account is inactive"
}

error = 500

{
    "success": false,
    "message": "Server error during admin login"
}

<!-- Admin -->
GET /api/admin/auth/profile

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Admin profile fetched successfully",
    "admin": {
        "id": 1,
        "name": "Admin",
        "email": "admin@gmail.com",
        "role": "ADMIN",
        "phone": "9000000000",
        "status": "ACTIVE",
        "created_at": "2026-01-01T08:00:00.000Z",
        "updated_at": "2026-01-01T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Admin not found"
}

error = 500

{
    "success": false,
    "message": "Server error while fetching admin profile"
}

# Member APIs

<!-- Member - Exercises -->
GET /api/member/exercises

auth = Bearer JWT

access = Role is not checked in the current implementation. Returns all ACTIVE exercises.

request = None

response = {
    "success": true,
    "message": "Exercises fetched successfully",
    "exercises": [
        {
            "id": 1,
            "name": "Bench Press",
            "muscle_group": "Chest",
            "equipment": "Barbell",
            "instructions": "Lie on the bench and press the bar up",
            "image_url": "https://example.com/bench-press.jpg",
            "video_url": "https://example.com/bench-press.mp4",
            "difficulty": "INTERMEDIATE"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch exercises"
}

<!-- Member - Challenges -->
GET /api/member/challenges

auth = Bearer JWT

access = Role is not checked in the current implementation. Returns all ACTIVE challenges.

request = None

response = {
    "success": true,
    "message": "Challenges fetched successfully",
    "challenges": [
        {
            "id": 1,
            "title": "30 Day Fitness Challenge",
            "description": "Complete workouts for 30 days",
            "start_date": "2026-09-01",
            "end_date": "2026-09-30",
            "reward": "Free protein shaker"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch challenges"
}

<!-- Member - Progress -->
POST /api/member/progress

auth = Bearer JWT

access = Own member data only. Role is not checked in the current implementation.

request = {
    "progress_date": "2026-09-09",
    "weight": 72.5,
    "body_fat": 18.2,
    "waist_cm": 82,
    "arms_cm": 34,
    "notes": "Feeling stronger this week"
}

response = {
    "success": true,
    "message": "Progress created successfully",
    "progress": {
        "id": 1,
        "progress_date": "2026-09-09",
        "weight": 72.5,
        "body_fat": 18.2,
        "waist_cm": 82,
        "arms_cm": 34,
        "notes": "Feeling stronger this week"
    }
}

error = 400

{
    "success": false,
    "message": "Progress date is required"
}

error = 409

{
    "success": false,
    "message": "Progress already exists for this date"
}

error = 500

{
    "success": false,
    "message": "Failed to create progress"
}

<!-- Member - Progress -->
GET /api/member/progress

auth = Bearer JWT

access = Own member data only. Role is not checked in the current implementation.

request = None

response = {
    "success": true,
    "message": "Progress fetched successfully",
    "progress": [
        {
            "id": 1,
            "progress_date": "2026-09-09",
            "weight": 72.5,
            "body_fat": 18.2,
            "waist_cm": 82,
            "arms_cm": 34,
            "notes": "Feeling stronger this week",
            "created_at": "2026-09-09T08:00:00.000Z",
            "updated_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch progress"
}

<!-- Member - Progress -->
GET /api/member/progress/5

auth = Bearer JWT

access = Own member data only. Role is not checked in the current implementation.

request = None

response = {
    "success": true,
    "message": "Progress fetched successfully",
    "progress": {
        "id": 5,
        "progress_date": "2026-09-09",
        "weight": 72.5,
        "body_fat": 18.2,
        "waist_cm": 82,
        "arms_cm": 34,
        "notes": "Feeling stronger this week",
        "created_at": "2026-09-09T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Progress not found"
}

error = 500

{
    "success": false,
    "message": "Failed to fetch progress"
}

<!-- Member - Progress -->
PUT /api/member/progress/5

auth = Bearer JWT

access = Own member data only. Role is not checked in the current implementation.

request = {
    "progress_date": "2026-09-09",
    "weight": 71.8,
    "body_fat": 17.9,
    "waist_cm": 81,
    "arms_cm": 34.5,
    "notes": "Updated measurements"
}

response = {
    "success": true,
    "message": "Progress updated successfully",
    "progress": {
        "id": 5,
        "progress_date": "2026-09-09",
        "weight": 71.8,
        "body_fat": 17.9,
        "waist_cm": 81,
        "arms_cm": 34.5,
        "notes": "Updated measurements",
        "created_at": "2026-09-09T08:00:00.000Z",
        "updated_at": "2026-09-09T09:00:00.000Z"
    }
}

error = 400

{
    "success": false,
    "message": "Progress date is required"
}

error = 404

{
    "success": false,
    "message": "Progress not found"
}

error = 409

{
    "success": false,
    "message": "Progress already exists for this date"
}

error = 500

{
    "success": false,
    "message": "Failed to update progress"
}

<!-- Member - Progress -->
DELETE /api/member/progress/5

auth = Bearer JWT

access = Own member data only. Role is not checked in the current implementation.

request = None

response = {
    "success": true,
    "message": "Progress deleted successfully"
}

error = 404

{
    "success": false,
    "message": "Progress not found"
}

error = 500

{
    "success": false,
    "message": "Failed to delete progress"
}

<!-- Member - Profile -->
POST /api/member/profile

auth = Bearer JWT

access = Own member data only. Role is not checked in the current implementation.

request = {
    "name": "Mohammed",
    "phone": "9876543210",
    "age": 24,
    "height": 175,
    "weight": 72.5,
    "fitness_goal": "Build muscle and improve overall fitness",
    "medical_notes": "No known injuries"
}

response = {
    "success": true,
    "message": "Profile created successfully",
    "profile": {
        "id": 1,
        "name": "Mohammed",
        "phone": "9876543210",
        "age": 24,
        "height": 175,
        "weight": 72.5,
        "fitness_goal": "Build muscle and improve overall fitness",
        "medical_notes": "No known injuries"
    }
}

error = 400

{
    "success": false,
    "message": "Name and phone are required"
}

error = 409

{
    "success": false,
    "message": "Profile already exists"
}

error = 500

{
    "success": false,
    "message": "Failed to create profile"
}

<!-- Member - Profile -->
GET /api/member/profile

auth = Bearer JWT

access = Own member data only. Role is not checked in the current implementation.

request = None

response = {
    "success": true,
    "message": "Profile fetched successfully",
    "profile": {
        "id": 1,
        "member_id": 1,
        "name": "Mohammed",
        "phone": "9876543210",
        "age": 24,
        "height": 175,
        "weight": 72.5,
        "fitness_goal": "Build muscle and improve overall fitness",
        "medical_notes": "No known injuries",
        "created_at": "2026-01-12T08:00:00.000Z",
        "updated_at": "2026-01-12T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Profile not found"
}

error = 500

{
    "success": false,
    "message": "Failed to fetch profile"
}

<!-- Member - Profile -->
PUT /api/member/profile

auth = Bearer JWT

access = Own member data only. Role is not checked in the current implementation.

request = {
    "name": "Mohammed",
    "phone": "9876543210",
    "age": 25,
    "height": 175,
    "weight": 71.8,
    "fitness_goal": "Build muscle and improve overall fitness",
    "medical_notes": "No known injuries"
}

response = {
    "success": true,
    "message": "Profile updated successfully",
    "profile": {
        "id": 1,
        "member_id": 1,
        "name": "Mohammed",
        "phone": "9876543210",
        "age": 25,
        "height": 175,
        "weight": 71.8,
        "fitness_goal": "Build muscle and improve overall fitness",
        "medical_notes": "No known injuries",
        "created_at": "2026-01-12T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 400

{
    "success": false,
    "message": "Name and phone are required"
}

error = 404

{
    "success": false,
    "message": "Profile not found"
}

error = 500

{
    "success": false,
    "message": "Failed to update profile"
}

<!-- Member - Notifications -->
GET /api/member/notifications

auth = Bearer JWT

access = Own member notifications only. Role is not checked in the current implementation.

request = None

response = {
    "count": 1,
    "notifications": [
        {
            "id": 1,
            "title": "New workout plan",
            "message": "Your trainer assigned a new workout plan",
            "is_read": 0,
            "created_at": "2026-09-09T08:00:00.000Z",
            "updated_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "message": "Server error"
}

<!-- Member - Notifications -->
PUT /api/member/notifications/1/read

auth = Bearer JWT

access = Own member notifications only. Role is not checked in the current implementation.

request = None

response = {
    "message": "Notification marked as read"
}

error = 200

{
    "message": "Notification is already marked as read"
}

error = 404

{
    "message": "Notification not found"
}

error = 500

{
    "message": "Server error"
}

<!-- Member - Class Schedules -->
GET /api/member/class-schedules

auth = Bearer JWT

role = MEMBER

access = Classes created by the member's assigned trainer only

request = None

response = {
    "count": 1,
    "classes": [
        {
            "id": 1,
            "trainer_id": 2,
            "title": "Morning HIIT",
            "class_date": "2026-09-10",
            "start_time": "07:00:00",
            "end_time": "08:00:00",
            "capacity": 20,
            "created_at": "2026-09-01T08:00:00.000Z",
            "updated_at": "2026-09-01T08:00:00.000Z",
            "trainer_name": "Ahmed",
            "trainer_email": "ahmed@gmail.com"
        }
    ]
}

error = 500

{
    "message": "Server error"
}

<!-- Member - Class Schedules -->
GET /api/member/class-schedules/1

auth = Bearer JWT

role = MEMBER

access = Classes created by the member's assigned trainer only

request = None

response = {
    "class": {
        "id": 1,
        "trainer_id": 2,
        "title": "Morning HIIT",
        "class_date": "2026-09-10",
        "start_time": "07:00:00",
        "end_time": "08:00:00",
        "capacity": 20,
        "created_at": "2026-09-01T08:00:00.000Z",
        "updated_at": "2026-09-01T08:00:00.000Z",
        "trainer_name": "Ahmed",
        "trainer_email": "ahmed@gmail.com"
    }
}

error = 404

{
    "message": "Class schedule not found or not available to you"
}

error = 500

{
    "message": "Server error"
}

<!-- Member - Workout Plans -->
GET /api/member/workout-plans

auth = Bearer JWT

role = MEMBER

access = Own assigned workout plans only

request = None

response = {
    "count": 1,
    "plans": [
        {
            "id": 1,
            "trainer_id": 2,
            "member_id": 1,
            "plan_name": "Push Pull Legs",
            "created_at": "2026-09-01T08:00:00.000Z",
            "updated_at": "2026-09-01T08:00:00.000Z",
            "trainer_name": "Ahmed",
            "trainer_email": "ahmed@gmail.com",
            "exercises": [
                {
                    "id": 10,
                    "workout_plan_id": 1,
                    "exercise_id": 3,
                    "exercise_name": "Bench Press",
                    "muscle_group": "Chest",
                    "equipment": "Barbell",
                    "instructions": "Lie on the bench and press the bar up",
                    "image_url": "https://example.com/bench-press.jpg",
                    "video_url": "https://example.com/bench-press.mp4",
                    "workout_day": "MONDAY",
                    "sets": 4,
                    "reps": 10,
                    "duration_minutes": 15,
                    "notes": "Keep elbows at 45 degrees",
                    "created_at": "2026-09-01T08:00:00.000Z",
                    "updated_at": "2026-09-01T08:00:00.000Z"
                }
            ]
        }
    ]
}

error = 500

{
    "message": "Failed to get workout plans"
}

<!-- Member - Workout Plans -->
GET /api/member/workout-plans/1

auth = Bearer JWT

role = MEMBER

access = Own assigned workout plans only

request = None

response = {
    "id": 1,
    "trainer_id": 2,
    "member_id": 1,
    "plan_name": "Push Pull Legs",
    "created_at": "2026-09-01T08:00:00.000Z",
    "updated_at": "2026-09-01T08:00:00.000Z",
    "trainer_name": "Ahmed",
    "trainer_email": "ahmed@gmail.com",
    "exercises": [
        {
            "id": 10,
            "workout_plan_id": 1,
            "exercise_id": 3,
            "exercise_name": "Bench Press",
            "muscle_group": "Chest",
            "equipment": "Barbell",
            "instructions": "Lie on the bench and press the bar up",
            "image_url": "https://example.com/bench-press.jpg",
            "video_url": "https://example.com/bench-press.mp4",
            "workout_day": "MONDAY",
            "sets": 4,
            "reps": 10,
            "duration_minutes": 15,
            "notes": "Keep elbows at 45 degrees",
            "created_at": "2026-09-01T08:00:00.000Z",
            "updated_at": "2026-09-01T08:00:00.000Z"
        }
    ]
}

error = 404

{
    "message": "Workout plan not found or not available to you"
}

error = 500

{
    "message": "Failed to get workout plan"
}

<!-- Member - Workout Plans -->
POST /api/member/workout-plans/1/exercises/10/complete

auth = Bearer JWT

role = MEMBER

access = Own assigned workout plans only

request = None

response = {
    "message": "Workout marked as completed",
    "completion": {
        "id": 1,
        "member_id": 1,
        "workout_plan_exercise_id": 10,
        "completed_date": "2026-09-09",
        "completed_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 404

{
    "message": "Workout plan not found"
}

error = 404

{
    "message": "Workout exercise not found"
}

error = 409

{
    "message": "Workout already marked as completed for today",
    "completion": {
        "id": 1,
        "member_id": 1,
        "workout_plan_exercise_id": 10,
        "completed_date": "2026-09-09",
        "completed_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 409

{
    "message": "Workout already marked as completed for today"
}

error = 500

{
    "message": "Failed to mark workout as completed"
}

<!-- Member - Diet Plans -->
GET /api/member/diet-plans

auth = Bearer JWT

role = MEMBER

access = Own assigned diet plans only

request = None

response = {
    "success": true,
    "count": 1,
    "diet_plans": [
        {
            "id": 1,
            "diet_day": "MONDAY",
            "meal_type": "BREAKFAST",
            "food_name": "Oats with banana",
            "calories": 350,
            "protein": 20,
            "notes": "Eat before workout",
            "created_at": "2026-09-01T08:00:00.000Z",
            "updated_at": "2026-09-01T08:00:00.000Z",
            "trainer_id": 2,
            "trainer_name": "Ahmed",
            "trainer_email": "ahmed@gmail.com"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch diet plans"
}

<!-- Member - Diet Plans -->
GET /api/member/diet-plans/1

auth = Bearer JWT

role = MEMBER

access = Own assigned diet plans only

request = None

response = {
    "success": true,
    "diet_plan": {
        "id": 1,
        "diet_day": "MONDAY",
        "meal_type": "BREAKFAST",
        "food_name": "Oats with banana",
        "calories": 350,
        "protein": 20,
        "notes": "Eat before workout",
        "created_at": "2026-09-01T08:00:00.000Z",
        "updated_at": "2026-09-01T08:00:00.000Z",
        "trainer_id": 2,
        "trainer_name": "Ahmed",
        "trainer_email": "ahmed@gmail.com"
    }
}

error = 404

{
    "success": false,
    "message": "Diet plan not found"
}

error = 500

{
    "success": false,
    "message": "Failed to fetch diet plan"
}

<!-- Member - Diet Plans -->
GET /api/member/diet-plans/today

auth = Bearer JWT

role = MEMBER

access = Own assigned diet plans only

request = None

response = {
    "success": true,
    "day": "WEDNESDAY",
    "count": 1,
    "diet_plans": [
        {
            "id": 1,
            "diet_day": "WEDNESDAY",
            "meal_type": "BREAKFAST",
            "food_name": "Oats with banana",
            "calories": 350,
            "protein": 20,
            "notes": "Eat before workout",
            "trainer_id": 2,
            "trainer_name": "Ahmed"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch today diet"
}

Note: This route is registered after `GET /api/member/diet-plans/:id` in the current implementation.

<!-- Member - Messages -->
GET /api/member/messages/trainer

auth = Bearer JWT

role = MEMBER

access = Assigned trainer only

request = None

response = {
    "success": true,
    "trainer": {
        "id": 2,
        "name": "Ahmed",
        "email": "ahmed@gmail.com",
        "phone": "9123456780",
        "status": "ACTIVE"
    }
}

error = 404

{
    "success": false,
    "message": "No trainer assigned to this member"
}

error = 500

{
    "success": false,
    "message": "Failed to fetch assigned trainer"
}

<!-- Member - Messages -->
GET /api/member/messages/2

auth = Bearer JWT

role = MEMBER

access = Assigned trainer conversation only

request = None

response = {
    "success": true,
    "trainer_id": 2,
    "trainer": {
        "id": 2,
        "name": "Ahmed",
        "email": "ahmed@gmail.com",
        "phone": "9123456780",
        "status": "ACTIVE"
    },
    "count": 1,
    "messages": [
        {
            "id": 1,
            "sender_id": 1,
            "sender_role": "MEMBER",
            "receiver_id": 2,
            "receiver_role": "TRAINER",
            "message": "Hi coach, I completed today's workout",
            "is_read": 0,
            "created_at": "2026-09-09T08:00:00.000Z",
            "updated_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 403

{
    "success": false,
    "message": "You can only access your assigned trainer conversation"
}

error = 404

{
    "success": false,
    "message": "No trainer assigned to this member"
}

error = 500

{
    "success": false,
    "message": "Failed to fetch conversation"
}

<!-- Member - Messages -->
POST /api/member/messages/2

auth = Bearer JWT

role = MEMBER

access = Assigned trainer only

request = {
    "message": "Hi coach, I completed today's workout"
}

response = {
    "success": true,
    "message": "Message sent successfully",
    "data": {
        "id": 1,
        "trainer_id": 2,
        "message": "Hi coach, I completed today's workout"
    }
}

error = 400

{
    "success": false,
    "message": "Message is required"
}

error = 403

{
    "success": false,
    "message": "You can only message your assigned trainer"
}

error = 404

{
    "success": false,
    "message": "No trainer assigned to this member"
}

error = 500

{
    "success": false,
    "message": "Failed to send message"
}

<!-- Member - Messages -->
PUT /api/member/messages/1/read

auth = Bearer JWT

role = MEMBER

access = Own received messages only

request = None

response = {
    "success": true,
    "message": "Message marked as read"
}

error = 404

{
    "success": false,
    "message": "Message not found"
}

error = 500

{
    "success": false,
    "message": "Failed to mark message as read"
}

<!-- Member - Dashboard -->
GET /api/member/dashboard/checkin-days

auth = Bearer JWT

role = MEMBER

access = Own member data only

request = None

response = {
    "success": true,
    "total": 12
}

error = 500

{
    "success": false,
    "message": "Failed to get check-in days"
}

<!-- Member - Dashboard -->
GET /api/member/dashboard/cheat-count

auth = Bearer JWT

role = MEMBER

access = Own member data only

request = None

response = {
    "success": true,
    "total": 3
}

error = 500

{
    "success": false,
    "message": "Failed to get current month cheat count"
}

<!-- Member - Dashboard -->
GET /api/member/dashboard/diet-plan

auth = Bearer JWT

role = MEMBER

access = Own member data only

request = None

response = {
    "success": true,
    "day": "WEDNESDAY",
    "count": 1,
    "diet_plans": [
        {
            "id": 1,
            "diet_day": "WEDNESDAY",
            "meal_type": "BREAKFAST",
            "food_name": "Oats with banana",
            "calories": 350,
            "protein": 20,
            "notes": "Eat before workout",
            "created_at": "2026-09-01T08:00:00.000Z",
            "updated_at": "2026-09-01T08:00:00.000Z",
            "trainer_id": 2,
            "trainer_name": "Ahmed",
            "trainer_email": "ahmed@gmail.com"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to get today diet plan"
}

<!-- Member - Dashboard -->
GET /api/member/dashboard/workout-plans

auth = Bearer JWT

role = MEMBER

access = Own member data only

request = None

response = {
    "success": true,
    "total": 2
}

error = 500

{
    "success": false,
    "message": "Failed to get workout plans count"
}

<!-- Member - Dashboard -->
GET /api/member/dashboard/notifications

auth = Bearer JWT

role = MEMBER

access = Own member data only

request = None

response = {
    "success": true,
    "total": 4
}

error = 500

{
    "success": false,
    "message": "Failed to get notification count"
}

<!-- Member - Dashboard -->
GET /api/member/dashboard/previous-month-progress

auth = Bearer JWT

role = MEMBER

access = Own member data only

request = None

response = {
    "success": true,
    "progress": {
        "id": 4,
        "member_id": 1,
        "progress_date": "2026-08-28",
        "weight": 73.1,
        "body_fat": 18.8,
        "waist_cm": 83,
        "arms_cm": 33.5,
        "notes": "End of August check-in",
        "created_at": "2026-08-28T08:00:00.000Z",
        "updated_at": "2026-08-28T08:00:00.000Z"
    }
}

error = 500

{
    "success": false,
    "message": "Failed to get previous month progress"
}

<!-- Member - Dashboard -->
GET /api/member/dashboard/today-workout

auth = Bearer JWT

role = MEMBER

access = Own member data only

request = None

response = {
    "success": true,
    "day": "WEDNESDAY",
    "count": 1,
    "workouts": [
        {
            "workout_plan_id": 1,
            "plan_name": "Push Pull Legs",
            "workout_plan_exercise_id": 10,
            "workout_day": "WEDNESDAY",
            "sets": 4,
            "reps": 10,
            "duration_minutes": 15,
            "notes": "Keep elbows at 45 degrees",
            "exercise_id": 3,
            "exercise_name": "Bench Press",
            "muscle_group": "Chest",
            "equipment": "Barbell",
            "instructions": "Lie on the bench and press the bar up",
            "image_url": "https://example.com/bench-press.jpg",
            "video_url": "https://example.com/bench-press.mp4",
            "difficulty": "INTERMEDIATE"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch today workout plans"
}

<!-- Member - Cheat Days -->
POST /api/member/cheat-days

auth = Bearer JWT

role = MEMBER

access = Own member data only

request = {
    "cheat_date": "2026-09-09",
    "food_name": "Pizza",
    "quantity": "2 slices",
    "calories": 600,
    "notes": "Weekend treat"
}

response = {
    "success": true,
    "message": "Cheat activity added successfully",
    "id": 1
}

error = 400

{
    "success": false,
    "message": "cheat_date and food_name are required"
}

error = 400

{
    "success": false,
    "message": "Calories cannot be negative"
}

error = 500

{
    "success": false,
    "message": "Failed to add cheat activity"
}

<!-- Member - Cheat Days -->
GET /api/member/cheat-days

auth = Bearer JWT

role = MEMBER

access = Own member data only

request = None

response = {
    "success": true,
    "count": 1,
    "cheat_days": [
        {
            "id": 1,
            "member_id": 1,
            "cheat_date": "2026-09-09",
            "food_name": "Pizza",
            "quantity": "2 slices",
            "calories": 600,
            "notes": "Weekend treat",
            "created_at": "2026-09-09T08:00:00.000Z",
            "updated_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch cheat activities"
}

<!-- Member - Cheat Days -->
GET /api/member/cheat-days/1

auth = Bearer JWT

role = MEMBER

access = Own member data only

request = None

response = {
    "success": true,
    "cheat_day": {
        "id": 1,
        "member_id": 1,
        "cheat_date": "2026-09-09",
        "food_name": "Pizza",
        "quantity": "2 slices",
        "calories": 600,
        "notes": "Weekend treat",
        "created_at": "2026-09-09T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Cheat activity not found"
}

error = 500

{
    "success": false,
    "message": "Failed to fetch cheat activity"
}

<!-- Member - Cheat Days -->
PUT /api/member/cheat-days/1

auth = Bearer JWT

role = MEMBER

access = Own member data only

request = {
    "cheat_date": "2026-09-09",
    "food_name": "Burger",
    "quantity": "1 burger",
    "calories": 550,
    "notes": "Updated entry"
}

response = {
    "success": true,
    "message": "Cheat activity updated successfully"
}

error = 400

{
    "success": false,
    "message": "cheat_date and food_name are required"
}

error = 400

{
    "success": false,
    "message": "Calories cannot be negative"
}

error = 404

{
    "success": false,
    "message": "Cheat activity not found"
}

error = 500

{
    "success": false,
    "message": "Failed to update cheat activity"
}

<!-- Member - Cheat Days -->
DELETE /api/member/cheat-days/1

auth = Bearer JWT

role = MEMBER

access = Own member data only

request = None

response = {
    "success": true,
    "message": "Cheat activity deleted successfully"
}

error = 404

{
    "success": false,
    "message": "Cheat activity not found"
}

error = 500

{
    "success": false,
    "message": "Failed to delete cheat activity"
}

# Trainer APIs

<!-- Trainer - Assigned Members -->
GET /api/trainer/assigned-members

auth = Bearer JWT

role = TRAINER

access = Trainer can access assigned members only

request = None

response = {
    "count": 1,
    "members": [
        {
            "id": 1,
            "name": "Mohammed",
            "email": "mohammed@gmail.com",
            "phone": "9876543210",
            "fitness_goal": "Build muscle and improve overall fitness",
            "status": "ACTIVE",
            "created_at": "2026-01-10T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "message": "Server error"
}

<!-- Trainer - Assigned Members -->
GET /api/trainer/assigned-members/1

auth = Bearer JWT

role = TRAINER

access = Trainer can access assigned members only

request = None

response = {
    "member": {
        "id": 1,
        "name": "Mohammed",
        "email": "mohammed@gmail.com",
        "phone": "9876543210",
        "status": "ACTIVE",
        "age": 24,
        "height": 175,
        "weight": 72.5,
        "fitness_goal": "Build muscle and improve overall fitness",
        "medical_notes": "No known injuries",
        "profile_created_at": "2026-01-12T08:00:00.000Z",
        "profile_updated_at": "2026-01-12T08:00:00.000Z"
    }
}

error = 404

{
    "message": "Member not found or member is not assigned to you"
}

error = 500

{
    "message": "Server error"
}

<!-- Trainer - Class Schedules -->
POST /api/trainer/class-schedules

auth = Bearer JWT

role = TRAINER

access = Own trainer classes only

request = {
    "title": "Morning HIIT",
    "class_date": "2026-09-10",
    "start_time": "07:00:00",
    "end_time": "08:00:00",
    "capacity": 20
}

response = {
    "message": "Class schedule created successfully",
    "class_id": 1
}

error = 400

{
    "message": "Title, date, start time, end time and capacity are required"
}

error = 400

{
    "message": "Capacity must be greater than 0"
}

error = 400

{
    "message": "End time must be after start time"
}

error = 500

{
    "message": "Server error"
}

<!-- Trainer - Class Schedules -->
GET /api/trainer/class-schedules

auth = Bearer JWT

role = TRAINER

access = Own trainer classes only

request = None

response = {
    "count": 1,
    "classes": [
        {
            "id": 1,
            "trainer_id": 2,
            "title": "Morning HIIT",
            "class_date": "2026-09-10",
            "start_time": "07:00:00",
            "end_time": "08:00:00",
            "capacity": 20,
            "created_at": "2026-09-01T08:00:00.000Z",
            "updated_at": "2026-09-01T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "message": "Server error"
}

<!-- Trainer - Class Schedules -->
GET /api/trainer/class-schedules/1

auth = Bearer JWT

role = TRAINER

access = Own trainer classes only

request = None

response = {
    "class": {
        "id": 1,
        "trainer_id": 2,
        "title": "Morning HIIT",
        "class_date": "2026-09-10",
        "start_time": "07:00:00",
        "end_time": "08:00:00",
        "capacity": 20,
        "created_at": "2026-09-01T08:00:00.000Z",
        "updated_at": "2026-09-01T08:00:00.000Z"
    }
}

error = 404

{
    "message": "Class schedule not found"
}

error = 500

{
    "message": "Server error"
}

<!-- Trainer - Class Schedules -->
PUT /api/trainer/class-schedules/1

auth = Bearer JWT

role = TRAINER

access = Own trainer classes only

request = {
    "title": "Evening Strength",
    "class_date": "2026-09-11",
    "start_time": "18:00:00",
    "end_time": "19:00:00",
    "capacity": 15
}

response = {
    "message": "Class schedule updated successfully",
    "class": {
        "id": 1,
        "trainer_id": 2,
        "title": "Evening Strength",
        "class_date": "2026-09-11",
        "start_time": "18:00:00",
        "end_time": "19:00:00",
        "capacity": 15,
        "created_at": "2026-09-01T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 400

{
    "message": "Title, date, start time, end time and capacity are required"
}

error = 400

{
    "message": "Capacity must be greater than 0"
}

error = 400

{
    "message": "End time must be after start time"
}

error = 404

{
    "message": "Class schedule not found"
}

error = 500

{
    "message": "Server error"
}

<!-- Trainer - Class Schedules -->
DELETE /api/trainer/class-schedules/1

auth = Bearer JWT

role = TRAINER

access = Own trainer classes only

request = None

response = {
    "message": "Class schedule deleted successfully"
}

error = 404

{
    "message": "Class schedule not found"
}

error = 500

{
    "message": "Server error"
}

<!-- Trainer - Workout Plans -->
POST /api/trainer/workout-plans

auth = Bearer JWT

role = TRAINER

access = Trainer can assign plans to assigned members only

request = {
    "member_id": 1,
    "plan_name": "Push Pull Legs",
    "exercise_id": 3,
    "workout_day": "MONDAY",
    "sets": 4,
    "reps": 10,
    "duration_minutes": 15,
    "notes": "Keep elbows at 45 degrees"
}

response = {
    "message": "Workout plan assigned successfully",
    "plan": {
        "id": 1,
        "trainer_id": 2,
        "member_id": 1,
        "member_name": "Mohammed",
        "plan_name": "Push Pull Legs"
    },
    "starter_exercise": {
        "id": 10,
        "exercise_id": 3,
        "exercise_name": "Bench Press",
        "workout_day": "MONDAY",
        "sets": 4,
        "reps": 10,
        "duration_minutes": 15,
        "notes": "Keep elbows at 45 degrees"
    }
}

error = 400

{
    "message": "member_id is required"
}

error = 400

{
    "message": "plan_name is required"
}

error = 400

{
    "message": "exercise_id is required"
}

error = 400

{
    "message": "workout_day is required"
}

error = 400

{
    "message": "Invalid workout_day"
}

error = 400

{
    "message": "Cannot assign workout to inactive member"
}

error = 404

{
    "message": "Member not found or not assigned to you"
}

error = 404

{
    "message": "Exercise not found or inactive"
}

error = 500

{
    "message": "Failed to assign workout plan"
}

<!-- Trainer - Workout Plans -->
GET /api/trainer/workout-plans

auth = Bearer JWT

role = TRAINER

access = Own trainer workout plans only

request = None

response = {
    "count": 1,
    "plans": [
        {
            "id": 1,
            "trainer_id": 2,
            "member_id": 1,
            "plan_name": "Push Pull Legs",
            "created_at": "2026-09-01T08:00:00.000Z",
            "updated_at": "2026-09-01T08:00:00.000Z",
            "member_name": "Mohammed",
            "member_email": "mohammed@gmail.com"
        }
    ]
}

error = 500

{
    "message": "Failed to fetch workout plans"
}

<!-- Trainer - Workout Plans -->
GET /api/trainer/workout-plans/1

auth = Bearer JWT

role = TRAINER

access = Own trainer workout plans only

request = None

response = {
    "plan": {
        "id": 1,
        "trainer_id": 2,
        "member_id": 1,
        "plan_name": "Push Pull Legs",
        "created_at": "2026-09-01T08:00:00.000Z",
        "updated_at": "2026-09-01T08:00:00.000Z",
        "member_name": "Mohammed",
        "member_email": "mohammed@gmail.com"
    },
    "exercises": [
        {
            "id": 10,
            "workout_plan_id": 1,
            "exercise_id": 3,
            "workout_day": "MONDAY",
            "sets": 4,
            "reps": 10,
            "duration_minutes": 15,
            "notes": "Keep elbows at 45 degrees",
            "exercise_name": "Bench Press",
            "muscle_group": "Chest",
            "equipment": "Barbell",
            "instructions": "Lie on the bench and press the bar up",
            "image_url": "https://example.com/bench-press.jpg",
            "video_url": "https://example.com/bench-press.mp4",
            "difficulty": "INTERMEDIATE"
        }
    ]
}

error = 404

{
    "message": "Workout plan not found"
}

error = 500

{
    "message": "Failed to fetch workout plan"
}

<!-- Trainer - Workout Plans -->
PUT /api/trainer/workout-plans/1

auth = Bearer JWT

role = TRAINER

access = Own trainer workout plans only

request = {
    "plan_name": "Upper Body Strength"
}

response = {
    "message": "Workout plan updated successfully",
    "plan": {
        "id": 1,
        "trainer_id": 2,
        "member_id": 1,
        "plan_name": "Upper Body Strength",
        "created_at": "2026-09-01T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z",
        "member_name": "Mohammed",
        "member_email": "mohammed@gmail.com"
    }
}

error = 400

{
    "message": "plan_name is required"
}

error = 404

{
    "message": "Workout plan not found"
}

error = 500

{
    "message": "Failed to update workout plan"
}

<!-- Trainer - Workout Plans -->
DELETE /api/trainer/workout-plans/1

auth = Bearer JWT

role = TRAINER

access = Own trainer workout plans only

request = None

response = {
    "message": "Workout plan deleted successfully"
}

error = 404

{
    "message": "Workout plan not found"
}

error = 500

{
    "message": "Failed to delete workout plan"
}

<!-- Trainer - Workout Plans -->
POST /api/trainer/workout-plans/1/exercises

auth = Bearer JWT

role = TRAINER

access = Own trainer workout plans only

request = {
    "exercise_id": 5,
    "workout_day": "WEDNESDAY",
    "sets": 3,
    "reps": 12,
    "duration_minutes": 10,
    "notes": "Slow tempo"
}

response = {
    "message": "Exercise added successfully",
    "workout_exercise_id": 11
}

error = 400

{
    "message": "exercise_id is required"
}

error = 400

{
    "message": "workout_day is required"
}

error = 400

{
    "message": "Invalid workout_day"
}

error = 404

{
    "message": "Workout plan not found"
}

error = 404

{
    "message": "Exercise not found or inactive"
}

error = 500

{
    "message": "Failed to add exercise"
}

<!-- Trainer - Workout Plans -->
PUT /api/trainer/workout-plans/1/exercises/10

auth = Bearer JWT

role = TRAINER

access = Own trainer workout plans only

request = {
    "exercise_id": 3,
    "workout_day": "FRIDAY",
    "sets": 5,
    "reps": 8,
    "duration_minutes": 20,
    "notes": "Increase weight"
}

response = {
    "message": "Workout exercise updated successfully"
}

error = 400

{
    "message": "exercise_id is required"
}

error = 400

{
    "message": "workout_day is required"
}

error = 400

{
    "message": "Invalid workout_day"
}

error = 404

{
    "message": "Workout plan not found"
}

error = 404

{
    "message": "Workout exercise not found"
}

error = 404

{
    "message": "Exercise not found or inactive"
}

error = 500

{
    "message": "Failed to update workout exercise"
}

<!-- Trainer - Workout Plans -->
DELETE /api/trainer/workout-plans/1/exercises/10

auth = Bearer JWT

role = TRAINER

access = Own trainer workout plans only

request = None

response = {
    "message": "Workout exercise deleted successfully"
}

error = 404

{
    "message": "Workout exercise not found"
}

error = 500

{
    "message": "Failed to delete workout exercise"
}

<!-- Trainer - Diet Plans -->
POST /api/trainer/diet-plans

auth = Bearer JWT

role = TRAINER

access = Trainer can assign diet to assigned members only

request = {
    "member_id": 1,
    "diet_day": "MONDAY",
    "meal_type": "BREAKFAST",
    "food_name": "Oats with banana",
    "calories": 350,
    "protein": 20,
    "notes": "Eat before workout"
}

response = {
    "success": true,
    "message": "Diet plan assigned successfully",
    "diet_plan": {
        "id": 1,
        "member_id": 1,
        "member_name": "Mohammed",
        "member_email": "mohammed@gmail.com",
        "diet_day": "MONDAY",
        "meal_type": "BREAKFAST",
        "food_name": "Oats with banana",
        "calories": 350,
        "protein": 20,
        "notes": "Eat before workout",
        "created_at": "2026-09-01T08:00:00.000Z",
        "updated_at": "2026-09-01T08:00:00.000Z"
    }
}

error = 400

{
    "success": false,
    "message": "member_id, diet_day, meal_type, food_name, calories and protein are required"
}

error = 400

{
    "success": false,
    "message": "Calories cannot be negative"
}

error = 400

{
    "success": false,
    "message": "Protein cannot be negative"
}

error = 400

{
    "success": false,
    "message": "Invalid diet day"
}

error = 400

{
    "success": false,
    "message": "Invalid meal type"
}

error = 403

{
    "success": false,
    "message": "This member is not assigned to you"
}

error = 500

{
    "success": false,
    "message": "Failed to assign diet plan"
}

<!-- Trainer - Diet Plans -->
GET /api/trainer/diet-plans

auth = Bearer JWT

role = TRAINER

access = Own trainer diet plans only

request = None

response = {
    "success": true,
    "count": 1,
    "diet_plans": [
        {
            "id": 1,
            "member_id": 1,
            "member_name": "Mohammed",
            "member_email": "mohammed@gmail.com",
            "diet_day": "MONDAY",
            "meal_type": "BREAKFAST",
            "food_name": "Oats with banana",
            "calories": 350,
            "protein": 20,
            "notes": "Eat before workout",
            "created_at": "2026-09-01T08:00:00.000Z",
            "updated_at": "2026-09-01T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch diet plans"
}

<!-- Trainer - Diet Plans -->
GET /api/trainer/diet-plans/1

auth = Bearer JWT

role = TRAINER

access = Own trainer diet plans only

request = None

response = {
    "success": true,
    "diet_plan": {
        "id": 1,
        "member_id": 1,
        "member_name": "Mohammed",
        "member_email": "mohammed@gmail.com",
        "diet_day": "MONDAY",
        "meal_type": "BREAKFAST",
        "food_name": "Oats with banana",
        "calories": 350,
        "protein": 20,
        "notes": "Eat before workout",
        "created_at": "2026-09-01T08:00:00.000Z",
        "updated_at": "2026-09-01T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Diet plan not found"
}

error = 500

{
    "success": false,
    "message": "Failed to fetch diet plan"
}

<!-- Trainer - Diet Plans -->
PUT /api/trainer/diet-plans/1

auth = Bearer JWT

role = TRAINER

access = Own trainer diet plans only

request = {
    "diet_day": "TUESDAY",
    "meal_type": "LUNCH",
    "food_name": "Grilled chicken rice",
    "calories": 520,
    "protein": 40,
    "notes": "Add vegetables"
}

response = {
    "success": true,
    "message": "Diet plan updated successfully",
    "diet_plan": {
        "id": 1,
        "member_id": 1,
        "member_name": "Mohammed",
        "member_email": "mohammed@gmail.com",
        "diet_day": "TUESDAY",
        "meal_type": "LUNCH",
        "food_name": "Grilled chicken rice",
        "calories": 520,
        "protein": 40,
        "notes": "Add vegetables",
        "created_at": "2026-09-01T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 400

{
    "success": false,
    "message": "diet_day, meal_type, food_name, calories and protein are required"
}

error = 400

{
    "success": false,
    "message": "Invalid diet day"
}

error = 400

{
    "success": false,
    "message": "Invalid meal type"
}

error = 400

{
    "success": false,
    "message": "Calories and protein cannot be negative"
}

error = 404

{
    "success": false,
    "message": "Diet plan not found"
}

error = 500

{
    "success": false,
    "message": "Failed to update diet plan"
}

<!-- Trainer - Diet Plans -->
DELETE /api/trainer/diet-plans/1

auth = Bearer JWT

role = TRAINER

access = Own trainer diet plans only

request = None

response = {
    "success": true,
    "message": "Diet plan deleted successfully"
}

error = 404

{
    "success": false,
    "message": "Diet plan not found"
}

error = 500

{
    "success": false,
    "message": "Failed to delete diet plan"
}

<!-- Trainer - Messages -->
GET /api/trainer/messages

auth = Bearer JWT

role = TRAINER

access = Assigned members with conversations only

request = None

response = {
    "success": true,
    "count": 1,
    "members": [
        {
            "id": 1,
            "name": "Mohammed",
            "email": "mohammed@gmail.com",
            "phone": "9876543210",
            "status": "ACTIVE",
            "last_message_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch message members"
}

<!-- Trainer - Messages -->
GET /api/trainer/messages/1

auth = Bearer JWT

role = TRAINER

access = Assigned members only

request = None

response = {
    "success": true,
    "member_id": 1,
    "count": 1,
    "messages": [
        {
            "id": 1,
            "sender_id": 2,
            "sender_role": "TRAINER",
            "receiver_id": 1,
            "receiver_role": "MEMBER",
            "message": "Great work today",
            "is_read": 0,
            "created_at": "2026-09-09T08:00:00.000Z",
            "updated_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 403

{
    "success": false,
    "message": "This member is not assigned to you"
}

error = 500

{
    "success": false,
    "message": "Failed to fetch conversation"
}

<!-- Trainer - Messages -->
POST /api/trainer/messages/1

auth = Bearer JWT

role = TRAINER

access = Assigned members only

request = {
    "message": "Great work today"
}

response = {
    "success": true,
    "message": "Message sent successfully",
    "data": {
        "id": 1,
        "member_id": 1,
        "message": "Great work today"
    }
}

error = 400

{
    "success": false,
    "message": "Message is required"
}

error = 403

{
    "success": false,
    "message": "This member is not assigned to you"
}

error = 500

{
    "success": false,
    "message": "Failed to send message"
}

<!-- Trainer - Messages -->
PUT /api/trainer/messages/1/read

auth = Bearer JWT

role = TRAINER

access = Own received messages only

request = None

response = {
    "success": true,
    "message": "Message marked as read"
}

error = 404

{
    "success": false,
    "message": "Message not found or already unavailable"
}

error = 500

{
    "success": false,
    "message": "Failed to mark message as read"
}

<!-- Trainer - Dashboard -->
GET /api/trainer/dashboard/assigned-members

auth = Bearer JWT

role = TRAINER

access = Own trainer dashboard data only

request = None

response = {
    "total": 8
}

error = 500

{
    "message": "Failed to get assigned members count"
}

<!-- Trainer - Dashboard -->
GET /api/trainer/dashboard/diet-plans

auth = Bearer JWT

role = TRAINER

access = Own trainer dashboard data only

request = None

response = {
    "total": 21
}

error = 500

{
    "message": "Failed to get diet plans count"
}

<!-- Trainer - Dashboard -->
GET /api/trainer/dashboard/workout-plans

auth = Bearer JWT

role = TRAINER

access = Own trainer dashboard data only

request = None

response = {
    "total": 6
}

error = 500

{
    "message": "Failed to get workout plans count"
}

<!-- Trainer - Dashboard -->
GET /api/trainer/dashboard/check-ins

auth = Bearer JWT

role = TRAINER

access = Assigned members only

request = None

response = {
    "count": 1,
    "members": [
        {
            "member_id": 1,
            "member_name": "Mohammed",
            "check_in_days": 12
        }
    ]
}

error = 500

{
    "message": "Failed to get workout check-ins"
}

<!-- Trainer - Cheat Days -->
GET /api/trainer/cheat-days/members

auth = Bearer JWT

role = TRAINER

access = Assigned members only

request = None

response = {
    "success": true,
    "count": 1,
    "members": [
        {
            "id": 1,
            "name": "Mohammed",
            "email": "mohammed@gmail.com",
            "phone": "9876543210",
            "status": "ACTIVE",
            "created_at": "2026-01-10T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch assigned members"
}

<!-- Trainer - Cheat Days -->
GET /api/trainer/cheat-days/current-month

auth = Bearer JWT

role = TRAINER

access = Assigned members only

request = None

response = {
    "success": true,
    "month": "CURRENT_MONTH",
    "count": 1,
    "cheat_days": [
        {
            "id": 1,
            "member_id": 1,
            "member_name": "Mohammed",
            "member_email": "mohammed@gmail.com",
            "cheat_date": "2026-09-09",
            "food_name": "Pizza",
            "quantity": "2 slices",
            "calories": 600,
            "notes": "Weekend treat",
            "created_at": "2026-09-09T08:00:00.000Z",
            "updated_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch current month cheat details"
}

<!-- Trainer - Cheat Days -->
GET /api/trainer/cheat-days/previous-month

auth = Bearer JWT

role = TRAINER

access = Assigned members only

request = None

response = {
    "success": true,
    "month": "PREVIOUS_MONTH",
    "count": 1,
    "cheat_days": [
        {
            "id": 2,
            "member_id": 1,
            "member_name": "Mohammed",
            "member_email": "mohammed@gmail.com",
            "cheat_date": "2026-08-20",
            "food_name": "Ice cream",
            "quantity": "1 bowl",
            "calories": 300,
            "notes": null,
            "created_at": "2026-08-20T08:00:00.000Z",
            "updated_at": "2026-08-20T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch previous month cheat details"
}

<!-- Trainer - Cheat Days -->
GET /api/trainer/cheat-days/members/1

auth = Bearer JWT

role = TRAINER

access = Assigned members only

request = None

response = {
    "success": true,
    "member_id": 1,
    "count": 1,
    "cheat_days": [
        {
            "id": 1,
            "member_id": 1,
            "cheat_date": "2026-09-09",
            "food_name": "Pizza",
            "quantity": "2 slices",
            "calories": 600,
            "notes": "Weekend treat",
            "created_at": "2026-09-09T08:00:00.000Z",
            "updated_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch member cheat activities"
}

<!-- Trainer - Cheat Days -->
GET /api/trainer/cheat-days/members/1/1

auth = Bearer JWT

role = TRAINER

access = Assigned members only

request = None

response = {
    "success": true,
    "cheat_day": {
        "id": 1,
        "member_id": 1,
        "cheat_date": "2026-09-09",
        "food_name": "Pizza",
        "quantity": "2 slices",
        "calories": 600,
        "notes": "Weekend treat",
        "created_at": "2026-09-09T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Cheat activity not found"
}

error = 500

{
    "success": false,
    "message": "Failed to fetch cheat activity"
}

# Admin APIs

<!-- Admin - Trainers -->
POST /api/admin/trainers

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = {
    "name": "Ahmed",
    "email": "ahmed@gmail.com",
    "phone": "9123456780",
    "password": "Trainer@123"
}

response = {
    "success": true,
    "message": "Trainer created successfully",
    "trainer": {
        "id": 2,
        "name": "Ahmed",
        "email": "ahmed@gmail.com",
        "phone": "9123456780",
        "role": "TRAINER",
        "status": "ACTIVE"
    }
}

error = 400

{
    "success": false,
    "message": "Name, email and password are required"
}

error = 409

{
    "success": false,
    "message": "User with this email already exists"
}

error = 500

{
    "success": false,
    "message": "Server error while creating trainer"
}

<!-- Admin - Trainers -->
GET /api/admin/trainers

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Trainers fetched successfully",
    "trainers": [
        {
            "id": 2,
            "name": "Ahmed",
            "email": "ahmed@gmail.com",
            "phone": "9123456780",
            "role": "TRAINER",
            "status": "ACTIVE",
            "created_at": "2026-01-05T08:00:00.000Z",
            "updated_at": "2026-01-05T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Server error while fetching trainers"
}

<!-- Admin - Trainers -->
GET /api/admin/trainers/2

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Trainer fetched successfully",
    "trainer": {
        "id": 2,
        "name": "Ahmed",
        "email": "ahmed@gmail.com",
        "phone": "9123456780",
        "role": "TRAINER",
        "status": "ACTIVE",
        "created_at": "2026-01-05T08:00:00.000Z",
        "updated_at": "2026-01-05T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Trainer not found"
}

error = 500

{
    "success": false,
    "message": "Server error while fetching trainer"
}

<!-- Admin - Trainers -->
DELETE /api/admin/trainers/2

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Trainer deleted successfully",
    "trainer": {
        "id": 2,
        "name": "Ahmed",
        "email": "ahmed@gmail.com",
        "phone": "9123456780",
        "role": "TRAINER",
        "status": "INACTIVE",
        "created_at": "2026-01-05T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 400

{
    "success": false,
    "message": "Trainer is already inactive"
}

error = 404

{
    "success": false,
    "message": "Trainer not found"
}

error = 500

{
    "success": false,
    "message": "Server error while deleting trainer"
}

<!-- Admin - Members -->
GET /api/admin/members

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Members fetched successfully",
    "members": [
        {
            "id": 1,
            "name": "Mohammed",
            "email": "mohammed@gmail.com",
            "phone": "9876543210",
            "fitness_goal": "Build muscle and improve overall fitness",
            "role": "MEMBER",
            "status": "ACTIVE",
            "created_at": "2026-01-10T08:00:00.000Z",
            "updated_at": "2026-01-10T08:00:00.000Z",
            "trainer_id": 2,
            "trainer_name": "Ahmed",
            "trainer_email": "ahmed@gmail.com"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Server error while fetching members"
}

<!-- Admin - Members -->
GET /api/admin/members/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Member fetched successfully",
    "member": {
        "id": 1,
        "name": "Mohammed",
        "email": "mohammed@gmail.com",
        "phone": "9876543210",
        "fitness_goal": "Build muscle and improve overall fitness",
        "role": "MEMBER",
        "status": "ACTIVE",
        "created_at": "2026-01-10T08:00:00.000Z",
        "updated_at": "2026-01-10T08:00:00.000Z",
        "trainer_id": 2,
        "trainer_name": "Ahmed",
        "trainer_email": "ahmed@gmail.com"
    }
}

error = 404

{
    "success": false,
    "message": "Member not found"
}

error = 500

{
    "success": false,
    "message": "Server error while fetching member"
}

<!-- Admin - Members -->
DELETE /api/admin/members/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Member deleted successfully",
    "member": {
        "id": 1,
        "name": "Mohammed",
        "email": "mohammed@gmail.com",
        "phone": "9876543210",
        "fitness_goal": "Build muscle and improve overall fitness",
        "role": "MEMBER",
        "status": "INACTIVE",
        "created_at": "2026-01-10T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z",
        "trainer_id": 2,
        "trainer_name": "Ahmed",
        "trainer_email": "ahmed@gmail.com"
    }
}

error = 400

{
    "success": false,
    "message": "Member is already inactive"
}

error = 404

{
    "success": false,
    "message": "Member not found"
}

error = 500

{
    "success": false,
    "message": "Server error while deleting member"
}

<!-- Admin - Members -->
PUT /api/admin/members/1/trainer

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = {
    "trainer_id": 2
}

response = {
    "success": true,
    "message": "Trainer assigned successfully",
    "member": {
        "id": 1,
        "name": "Mohammed",
        "email": "mohammed@gmail.com",
        "phone": "9876543210",
        "fitness_goal": "Build muscle and improve overall fitness",
        "role": "MEMBER",
        "status": "ACTIVE",
        "created_at": "2026-01-10T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z",
        "trainer_id": 2,
        "trainer_name": "Ahmed",
        "trainer_email": "ahmed@gmail.com"
    }
}

error = 400

{
    "success": false,
    "message": "Trainer ID is required"
}

error = 400

{
    "success": false,
    "message": "Cannot assign trainer to inactive member"
}

error = 400

{
    "success": false,
    "message": "Cannot assign an inactive trainer"
}

error = 404

{
    "success": false,
    "message": "Member not found"
}

error = 404

{
    "success": false,
    "message": "Trainer not found"
}

error = 500

{
    "success": false,
    "message": "Server error while assigning trainer"
}

<!-- Admin - Members -->
DELETE /api/admin/members/1/trainer

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Trainer removed successfully",
    "member": {
        "id": 1,
        "name": "Mohammed",
        "email": "mohammed@gmail.com",
        "phone": "9876543210",
        "fitness_goal": "Build muscle and improve overall fitness",
        "role": "MEMBER",
        "status": "ACTIVE",
        "created_at": "2026-01-10T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z",
        "trainer_id": null,
        "trainer_name": null,
        "trainer_email": null
    }
}

error = 404

{
    "success": false,
    "message": "Member not found"
}

error = 500

{
    "success": false,
    "message": "Server error while removing trainer"
}

<!-- Admin - Plans -->
POST /api/admin/plans

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = {
    "name": "Gold Plan",
    "description": "Full gym access with trainer support",
    "duration_value": 3,
    "duration_unit": "MONTH",
    "price": 4999,
    "extra_features": "Sauna and locker included"
}

response = {
    "success": true,
    "message": "Plan created successfully",
    "plan": {
        "id": 1,
        "name": "Gold Plan",
        "description": "Full gym access with trainer support",
        "duration_value": 3,
        "duration_unit": "MONTH",
        "price": 4999,
        "extra_features": "Sauna and locker included",
        "status": "ACTIVE",
        "created_at": "2026-09-09T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 400

{
    "success": false,
    "message": "Name, duration value, duration unit and price are required"
}

error = 400

{
    "success": false,
    "message": "Duration value must be a positive integer"
}

error = 400

{
    "success": false,
    "message": "Duration unit must be DAY, MONTH or YEAR"
}

error = 400

{
    "success": false,
    "message": "Price must be a valid non-negative number"
}

error = 400

{
    "success": false,
    "message": "Extra features must be text"
}

error = 409

{
    "success": false,
    "message": "A plan with this name already exists"
}

error = 500

{
    "success": false,
    "message": "Server error while creating plan"
}

<!-- Admin - Plans -->
GET /api/admin/plans

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Plans fetched successfully",
    "plans": [
        {
            "id": 1,
            "name": "Gold Plan",
            "description": "Full gym access with trainer support",
            "duration_value": 3,
            "duration_unit": "MONTH",
            "price": 4999,
            "extra_features": "Sauna and locker included",
            "status": "ACTIVE",
            "created_at": "2026-09-09T08:00:00.000Z",
            "updated_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Server error while fetching plans"
}

<!-- Admin - Plans -->
GET /api/admin/plans/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Plan fetched successfully",
    "plan": {
        "id": 1,
        "name": "Gold Plan",
        "description": "Full gym access with trainer support",
        "duration_value": 3,
        "duration_unit": "MONTH",
        "price": 4999,
        "extra_features": "Sauna and locker included",
        "status": "ACTIVE",
        "created_at": "2026-09-09T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Plan not found"
}

error = 500

{
    "success": false,
    "message": "Server error while fetching plan"
}

<!-- Admin - Promotions -->
POST /api/admin/promotions

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = {
    "title": "New Year Offer",
    "code": "NY2026",
    "description": "20 percent off all plans",
    "discount": 20,
    "discount_type": "PERCENTAGE",
    "start_date": "2026-01-01",
    "end_date": "2026-01-31"
}

response = {
    "success": true,
    "message": "Promotion created successfully",
    "promotion": {
        "id": 1,
        "title": "New Year Offer",
        "code": "NY2026",
        "description": "20 percent off all plans",
        "discount": 20,
        "discount_type": "PERCENTAGE",
        "start_date": "2026-01-01",
        "end_date": "2026-01-31",
        "status": "ACTIVE",
        "created_at": "2026-01-01T08:00:00.000Z",
        "updated_at": "2026-01-01T08:00:00.000Z"
    }
}

error = 400

{
    "success": false,
    "message": "Title, code, discount, discount type, start date and end date are required"
}

error = 400

{
    "success": false,
    "message": "Title cannot be empty"
}

error = 400

{
    "success": false,
    "message": "Promotion code cannot be empty"
}

error = 400

{
    "success": false,
    "message": "Discount type must be PERCENTAGE or FIXED"
}

error = 400

{
    "success": false,
    "message": "Discount must be a valid non-negative number"
}

error = 400

{
    "success": false,
    "message": "Percentage discount cannot exceed 100"
}

error = 400

{
    "success": false,
    "message": "Invalid start date or end date"
}

error = 400

{
    "success": false,
    "message": "End date must be after start date"
}

error = 400

{
    "success": false,
    "message": "A promotion with this code already exists"
}

error = 500

{
    "success": false,
    "message": "Server error while creating promotion"
}

<!-- Admin - Promotions -->
GET /api/admin/promotions

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Promotions fetched successfully",
    "promotions": [
        {
            "id": 1,
            "title": "New Year Offer",
            "code": "NY2026",
            "description": "20 percent off all plans",
            "discount": 20,
            "discount_type": "PERCENTAGE",
            "start_date": "2026-01-01",
            "end_date": "2026-01-31",
            "status": "ACTIVE",
            "created_at": "2026-01-01T08:00:00.000Z",
            "updated_at": "2026-01-01T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Server error while fetching promotions"
}

<!-- Admin - Promotions -->
GET /api/admin/promotions/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Promotion fetched successfully",
    "promotion": {
        "id": 1,
        "title": "New Year Offer",
        "code": "NY2026",
        "description": "20 percent off all plans",
        "discount": 20,
        "discount_type": "PERCENTAGE",
        "start_date": "2026-01-01",
        "end_date": "2026-01-31",
        "status": "ACTIVE",
        "created_at": "2026-01-01T08:00:00.000Z",
        "updated_at": "2026-01-01T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Promotion not found"
}

error = 500

{
    "success": false,
    "message": "Server error while fetching promotion"
}

<!-- Admin - Promotions -->
PUT /api/admin/promotions/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = {
    "title": "New Year Offer",
    "code": "NY2026",
    "description": "25 percent off all plans",
    "discount": 25,
    "discount_type": "PERCENTAGE",
    "start_date": "2026-01-01",
    "end_date": "2026-01-31",
    "status": "ACTIVE"
}

response = {
    "success": true,
    "message": "Promotion updated successfully",
    "promotion": {
        "id": 1,
        "title": "New Year Offer",
        "code": "NY2026",
        "description": "25 percent off all plans",
        "discount": 25,
        "discount_type": "PERCENTAGE",
        "start_date": "2026-01-01",
        "end_date": "2026-01-31",
        "status": "ACTIVE",
        "created_at": "2026-01-01T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 400

{
    "success": false,
    "message": "Status must be ACTIVE or INACTIVE"
}

error = 404

{
    "success": false,
    "message": "Promotion not found"
}

error = 500

{
    "success": false,
    "message": "Server error while updating promotion"
}

<!-- Admin - Promotions -->
DELETE /api/admin/promotions/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Promotion deleted successfully"
}

error = 404

{
    "success": false,
    "message": "Promotion not found"
}

error = 500

{
    "success": false,
    "message": "Server error while deleting promotion"
}

<!-- Admin - Challenges -->
POST /api/admin/challenges

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = {
    "title": "30 Day Fitness Challenge",
    "description": "Complete workouts for 30 days",
    "start_date": "2026-09-01",
    "end_date": "2026-09-30",
    "reward": "Free protein shaker"
}

response = {
    "success": true,
    "message": "Challenge created successfully",
    "challenge": {
        "id": 1,
        "title": "30 Day Fitness Challenge",
        "description": "Complete workouts for 30 days",
        "start_date": "2026-09-01",
        "end_date": "2026-09-30",
        "reward": "Free protein shaker",
        "status": "ACTIVE",
        "created_at": "2026-09-01T08:00:00.000Z",
        "updated_at": "2026-09-01T08:00:00.000Z"
    }
}

error = 400

{
    "success": false,
    "message": "Title, start date and end date are required"
}

error = 400

{
    "success": false,
    "message": "Title cannot be empty"
}

error = 400

{
    "success": false,
    "message": "Invalid start date or end date"
}

error = 400

{
    "success": false,
    "message": "End date must be after start date"
}

error = 500

{
    "success": false,
    "message": "Server error while creating challenge"
}

<!-- Admin - Challenges -->
GET /api/admin/challenges

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Challenges fetched successfully",
    "challenges": [
        {
            "id": 1,
            "title": "30 Day Fitness Challenge",
            "description": "Complete workouts for 30 days",
            "start_date": "2026-09-01",
            "end_date": "2026-09-30",
            "reward": "Free protein shaker",
            "status": "ACTIVE",
            "created_at": "2026-09-01T08:00:00.000Z",
            "updated_at": "2026-09-01T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Server error while fetching challenges"
}

<!-- Admin - Challenges -->
GET /api/admin/challenges/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Challenge fetched successfully",
    "challenge": {
        "id": 1,
        "title": "30 Day Fitness Challenge",
        "description": "Complete workouts for 30 days",
        "start_date": "2026-09-01",
        "end_date": "2026-09-30",
        "reward": "Free protein shaker",
        "status": "ACTIVE",
        "created_at": "2026-09-01T08:00:00.000Z",
        "updated_at": "2026-09-01T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Challenge not found"
}

error = 500

{
    "success": false,
    "message": "Server error while fetching challenge"
}

<!-- Admin - Challenges -->
PUT /api/admin/challenges/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = {
    "title": "30 Day Fitness Challenge",
    "description": "Complete workouts for 30 days",
    "start_date": "2026-09-01",
    "end_date": "2026-09-30",
    "reward": "Free gym t-shirt",
    "status": "ACTIVE"
}

response = {
    "success": true,
    "message": "Challenge updated successfully",
    "challenge": {
        "id": 1,
        "title": "30 Day Fitness Challenge",
        "description": "Complete workouts for 30 days",
        "start_date": "2026-09-01",
        "end_date": "2026-09-30",
        "reward": "Free gym t-shirt",
        "status": "ACTIVE",
        "created_at": "2026-09-01T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 400

{
    "success": false,
    "message": "Title, start date and end date are required"
}

error = 400

{
    "success": false,
    "message": "Title cannot be empty"
}

error = 400

{
    "success": false,
    "message": "Invalid start date or end date"
}

error = 400

{
    "success": false,
    "message": "End date must be after start date"
}

error = 400

{
    "success": false,
    "message": "Status must be ACTIVE or INACTIVE"
}

error = 404

{
    "success": false,
    "message": "Challenge not found"
}

error = 500

{
    "success": false,
    "message": "Server error while updating challenge"
}

<!-- Admin - Challenges -->
DELETE /api/admin/challenges/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Challenge deleted successfully"
}

error = 404

{
    "success": false,
    "message": "Challenge not found"
}

error = 500

{
    "success": false,
    "message": "Server error while deleting challenge"
}

<!-- Admin - Notifications -->
POST /api/admin/notifications/members

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = {
    "title": "Gym Holiday",
    "message": "The gym will be closed on Sunday"
}

response = {
    "message": "Notification sent to all members",
    "recipients": 25
}

error = 400

{
    "message": "Title and message are required"
}

error = 404

{
    "message": "No members found"
}

error = 500

{
    "message": "Server error"
}

<!-- Admin - Notifications -->
POST /api/admin/notifications/trainers

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = {
    "title": "Staff Meeting",
    "message": "All trainers must attend the Monday meeting"
}

response = {
    "message": "Notification sent to all trainers",
    "recipients": 5
}

error = 400

{
    "message": "Title and message are required"
}

error = 404

{
    "message": "No trainers found"
}

error = 500

{
    "message": "Server error"
}

<!-- Admin - Notifications -->
POST /api/admin/notifications/member/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = {
    "title": "Membership Reminder",
    "message": "Your membership expires next week"
}

response = {
    "message": "Notification sent to member",
    "notification_id": 10,
    "member_id": 1
}

error = 400

{
    "message": "Title and message are required"
}

error = 404

{
    "message": "Member not found"
}

error = 500

{
    "message": "Server error"
}

<!-- Admin - Notifications -->
POST /api/admin/notifications/trainer/2

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = {
    "title": "Schedule Update",
    "message": "Please update your class schedule"
}

response = {
    "message": "Notification sent to trainer",
    "notification_id": 11,
    "trainer_id": 2
}

error = 400

{
    "message": "Title and message are required"
}

error = 404

{
    "message": "Trainer not found"
}

error = 500

{
    "message": "Server error"
}

<!-- Admin - Notifications -->
GET /api/admin/notifications

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "count": 1,
    "notifications": [
        {
            "id": 1,
            "recipient_id": 1,
            "recipient_role": "MEMBER",
            "title": "Gym Holiday",
            "message": "The gym will be closed on Sunday",
            "is_read": 0,
            "created_at": "2026-09-09T08:00:00.000Z",
            "updated_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "message": "Server error"
}

<!-- Admin - Exercises -->
POST /api/admin/exercises

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = {
    "name": "Bench Press",
    "muscle_group": "Chest",
    "equipment": "Barbell",
    "instructions": "Lie on the bench and press the bar up",
    "image_url": "https://example.com/bench-press.jpg",
    "video_url": "https://example.com/bench-press.mp4",
    "difficulty": "INTERMEDIATE"
}

response = {
    "success": true,
    "message": "Exercise created successfully",
    "exercise": {
        "id": 1,
        "name": "Bench Press",
        "muscle_group": "Chest",
        "equipment": "Barbell",
        "instructions": "Lie on the bench and press the bar up",
        "image_url": "https://example.com/bench-press.jpg",
        "video_url": "https://example.com/bench-press.mp4",
        "difficulty": "INTERMEDIATE",
        "status": "ACTIVE",
        "created_at": "2026-09-09T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 400

{
    "success": false,
    "message": "Name and difficulty are required"
}

error = 400

{
    "success": false,
    "message": "Exercise name cannot be empty"
}

error = 400

{
    "success": false,
    "message": "Difficulty must be BEGINNER, INTERMEDIATE or DIFFICULT"
}

error = 409

{
    "success": false,
    "message": "An exercise with this name already exists"
}

error = 500

{
    "success": false,
    "message": "Server error while creating exercise"
}

<!-- Admin - Exercises -->
GET /api/admin/exercises

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Exercises fetched successfully",
    "exercises": [
        {
            "id": 1,
            "name": "Bench Press",
            "muscle_group": "Chest",
            "equipment": "Barbell",
            "instructions": "Lie on the bench and press the bar up",
            "image_url": "https://example.com/bench-press.jpg",
            "video_url": "https://example.com/bench-press.mp4",
            "difficulty": "INTERMEDIATE",
            "status": "ACTIVE",
            "created_at": "2026-09-09T08:00:00.000Z",
            "updated_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Server error while fetching exercises"
}

<!-- Admin - Exercises -->
GET /api/admin/exercises/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Exercise fetched successfully",
    "exercise": {
        "id": 1,
        "name": "Bench Press",
        "muscle_group": "Chest",
        "equipment": "Barbell",
        "instructions": "Lie on the bench and press the bar up",
        "image_url": "https://example.com/bench-press.jpg",
        "video_url": "https://example.com/bench-press.mp4",
        "difficulty": "INTERMEDIATE",
        "status": "ACTIVE",
        "created_at": "2026-09-09T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Exercise not found"
}

error = 500

{
    "success": false,
    "message": "Server error while fetching exercise"
}

<!-- Admin - Exercises -->
PUT /api/admin/exercises/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = {
    "name": "Incline Bench Press",
    "muscle_group": "Chest",
    "equipment": "Barbell",
    "instructions": "Set the bench to incline and press the bar up",
    "image_url": "https://example.com/incline-bench.jpg",
    "video_url": "https://example.com/incline-bench.mp4",
    "difficulty": "INTERMEDIATE",
    "status": "ACTIVE"
}

response = {
    "success": true,
    "message": "Exercise updated successfully",
    "exercise": {
        "id": 1,
        "name": "Incline Bench Press",
        "muscle_group": "Chest",
        "equipment": "Barbell",
        "instructions": "Set the bench to incline and press the bar up",
        "image_url": "https://example.com/incline-bench.jpg",
        "video_url": "https://example.com/incline-bench.mp4",
        "difficulty": "INTERMEDIATE",
        "status": "ACTIVE",
        "created_at": "2026-09-09T08:00:00.000Z",
        "updated_at": "2026-09-09T09:00:00.000Z"
    }
}

error = 400

{
    "success": false,
    "message": "Name and difficulty are required"
}

error = 400

{
    "success": false,
    "message": "Exercise name cannot be empty"
}

error = 400

{
    "success": false,
    "message": "Difficulty must be BEGINNER, INTERMEDIATE or DIFFICULT"
}

error = 400

{
    "success": false,
    "message": "Status must be ACTIVE or INACTIVE"
}

error = 404

{
    "success": false,
    "message": "Exercise not found"
}

error = 409

{
    "success": false,
    "message": "An exercise with this name already exists"
}

error = 500

{
    "success": false,
    "message": "Server error while updating exercise"
}

<!-- Admin - Exercises -->
DELETE /api/admin/exercises/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Exercise deleted successfully"
}

error = 404

{
    "success": false,
    "message": "Exercise not found"
}

error = 500

{
    "success": false,
    "message": "Server error while deleting exercise"
}

<!-- Admin - Contacts -->
GET /api/admin/contacts

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "Mohammed",
            "email": "mohammed@gmail.com",
            "phone": "9876543210",
            "message": "I want to know about gym membership plans",
            "status": "NEW",
            "created_at": "2026-09-09T08:00:00.000Z",
            "updated_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch contact enquiries"
}

<!-- Admin - Contacts -->
GET /api/admin/contacts/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "data": {
        "id": 1,
        "name": "Mohammed",
        "email": "mohammed@gmail.com",
        "phone": "9876543210",
        "message": "I want to know about gym membership plans",
        "status": "READ",
        "created_at": "2026-09-09T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Contact enquiry not found"
}

error = 500

{
    "success": false,
    "message": "Failed to fetch contact enquiry"
}

<!-- Admin - Contacts -->
DELETE /api/admin/contacts/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Contact enquiry deleted successfully"
}

error = 404

{
    "success": false,
    "message": "Contact enquiry not found"
}

error = 500

{
    "success": false,
    "message": "Failed to delete contact enquiry"
}

<!-- Admin - Dashboard -->
GET /api/admin/dashboard/member

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "data": {
        "total_members": 40,
        "active_members": 35,
        "inactive_members": 5
    }
}

error = 500

{
    "success": false,
    "message": "Failed to load member dashboard data"
}

<!-- Admin - Dashboard -->
GET /api/admin/dashboard/trainer

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "data": {
        "total_trainers": 8,
        "active_trainers": 7,
        "inactive_trainers": 1
    }
}

error = 500

{
    "success": false,
    "message": "Failed to load trainer dashboard data"
}

<!-- Admin - Dashboard -->
GET /api/admin/dashboard/plan

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "data": {
        "total_plans": 4
    }
}

error = 500

{
    "success": false,
    "message": "Failed to load plan dashboard data"
}

<!-- Admin - Dashboard -->
GET /api/admin/dashboard/promotion

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "data": {
        "total_promotions": 3
    }
}

error = 500

{
    "success": false,
    "message": "Failed to load promotion dashboard data"
}

<!-- Admin - Dashboard -->
GET /api/admin/dashboard/challenge

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "data": {
        "total_challenges": 2
    }
}

error = 500

{
    "success": false,
    "message": "Failed to load challenge dashboard data"
}

<!-- Admin - Dashboard -->
GET /api/admin/dashboard/recent/plan

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "Gold Plan",
            "description": "Full gym access with trainer support",
            "duration_value": 3,
            "duration_unit": "MONTH",
            "price": 4999,
            "extra_features": "Sauna and locker included",
            "status": "ACTIVE",
            "created_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to load recent plans"
}

<!-- Admin - Dashboard -->
GET /api/admin/dashboard/recent/promotion

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "data": [
        {
            "id": 1,
            "title": "New Year Offer",
            "code": "NY2026",
            "description": "20 percent off all plans",
            "discount": 20,
            "discount_type": "PERCENTAGE",
            "start_date": "2026-01-01",
            "end_date": "2026-01-31",
            "status": "ACTIVE",
            "created_at": "2026-01-01T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to load recent promotions"
}

<!-- Admin - Dashboard -->
GET /api/admin/dashboard/recent/challenge

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "data": [
        {
            "id": 1,
            "title": "30 Day Fitness Challenge",
            "description": "Complete workouts for 30 days",
            "start_date": "2026-09-01",
            "end_date": "2026-09-30",
            "reward": "Free protein shaker",
            "status": "ACTIVE",
            "created_at": "2026-09-01T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to load recent challenges"
}

<!-- Admin - Content -->
POST /api/admin/content

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = multipart/form-data {
    "title": "Summer Fitness Tips",
    "description": "Stay hydrated and train consistently",
    "image": "file"
}

response = {
    "success": true,
    "message": "Content created successfully",
    "data": {
        "id": 1,
        "title": "Summer Fitness Tips",
        "image": "/uploads/content/1710000000000-123456789.jpg",
        "description": "Stay hydrated and train consistently"
    }
}

error = 400

{
    "success": false,
    "message": "Title and description are required"
}

error = 400

{
    "success": false,
    "message": "Image is required"
}

error = 500

{
    "success": false,
    "message": "Failed to create content"
}

<!-- Admin - Content -->
GET /api/admin/content

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "data": [
        {
            "id": 1,
            "title": "Summer Fitness Tips",
            "image": "/uploads/content/1710000000000-123456789.jpg",
            "description": "Stay hydrated and train consistently",
            "created_at": "2026-09-09T08:00:00.000Z",
            "updated_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch content"
}

<!-- Admin - Content -->
GET /api/admin/content/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "data": {
        "id": 1,
        "title": "Summer Fitness Tips",
        "image": "/uploads/content/1710000000000-123456789.jpg",
        "description": "Stay hydrated and train consistently",
        "created_at": "2026-09-09T08:00:00.000Z",
        "updated_at": "2026-09-09T08:00:00.000Z"
    }
}

error = 404

{
    "success": false,
    "message": "Content not found"
}

error = 500

{
    "success": false,
    "message": "Failed to fetch content"
}

<!-- Admin - Content -->
PUT /api/admin/content/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = multipart/form-data {
    "title": "Winter Fitness Tips",
    "description": "Keep training during winter",
    "image": "file"
}

response = {
    "success": true,
    "message": "Content updated successfully"
}

error = 400

{
    "success": false,
    "message": "Title and description are required"
}

error = 404

{
    "success": false,
    "message": "Content not found"
}

error = 500

{
    "success": false,
    "message": "Failed to update content"
}

<!-- Admin - Content -->
DELETE /api/admin/content/1

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Content deleted successfully"
}

error = 404

{
    "success": false,
    "message": "Content not found"
}

error = 500

{
    "success": false,
    "message": "Failed to delete content"
}

<!-- Admin - Analytics -->
GET /api/admin/analytics/member

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Member analytics fetched successfully",
    "data": {
        "total_members": 40,
        "current_month_joined": 2,
        "current_month_members": [
            {
                "id": 1,
                "name": "Mohammed",
                "email": "mohammed@gmail.com",
                "phone": "9876543210",
                "joined_date": "2026-09-02T08:00:00.000Z"
            }
        ]
    }
}

error = 500

{
    "success": false,
    "message": "Failed to fetch member analytics"
}

<!-- Admin - Analytics -->
GET /api/admin/analytics/trainer

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Trainer analytics fetched successfully",
    "data": {
        "total_trainers": 8,
        "current_month_joined": 1,
        "current_month_trainers": [
            {
                "id": 2,
                "name": "Ahmed",
                "email": "ahmed@gmail.com",
                "phone": "9123456780",
                "joined_date": "2026-09-03T08:00:00.000Z"
            }
        ]
    }
}

error = 500

{
    "success": false,
    "message": "Failed to fetch trainer analytics"
}

<!-- Admin - Analytics -->
GET /api/admin/analytics/plan

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Recent plans fetched successfully",
    "data": [
        {
            "id": 1,
            "name": "Gold Plan",
            "description": "Full gym access with trainer support",
            "duration_value": 3,
            "duration_unit": "MONTH",
            "price": 4999,
            "extra_features": "Sauna and locker included",
            "status": "ACTIVE",
            "created_at": "2026-09-09T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch recent plans"
}

<!-- Admin - Analytics -->
GET /api/admin/analytics/promotion

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Recent promotions fetched successfully",
    "data": [
        {
            "id": 1,
            "title": "New Year Offer",
            "code": "NY2026",
            "description": "20 percent off all plans",
            "discount": 20,
            "discount_type": "PERCENTAGE",
            "start_date": "2026-01-01",
            "end_date": "2026-01-31",
            "status": "ACTIVE",
            "created_at": "2026-01-01T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch recent promotions"
}

<!-- Admin - Analytics -->
GET /api/admin/analytics/challenge

auth = Bearer JWT

role = ADMIN

access = ADMIN only

request = None

response = {
    "success": true,
    "message": "Recent challenges fetched successfully",
    "data": [
        {
            "id": 1,
            "title": "30 Day Fitness Challenge",
            "description": "Complete workouts for 30 days",
            "start_date": "2026-09-01",
            "end_date": "2026-09-30",
            "reward": "Free protein shaker",
            "status": "ACTIVE",
            "created_at": "2026-09-01T08:00:00.000Z"
        }
    ]
}

error = 500

{
    "success": false,
    "message": "Failed to fetch recent challenges"
}


