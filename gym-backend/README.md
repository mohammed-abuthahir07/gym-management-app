http://localhost:5000
<!-- Member -->
POST /api/member/auth/register
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
    "member": {
        "id": 1,
        "name": "Mohammed",
        "email": "mohammed@gmail.com",
        "phone": "9876543210",
        "fitness_goal": "Build muscle and improve overall fitness",
        "role": "MEMBER",
        "status": "ACTIVE"
    }
}

POST /api/member/auth/login

request = {
    "email": "mohammed@gmail.com",
    "password": "Member@123"
}

response = {
    "success": true,
    "message": "Member login successful",
    "token": "JWT_TOKEN_HERE",
    "member": {
        "id": 1,
        "name": "Mohammed",
        "email": "mohammed@gmail.com",
        "role": "MEMBER",
        "phone": "9876543210",
        "fitness_goal": "Build muscle and improve overall fitness",
        "status": "ACTIVE"
    }
}

GET (http://localhost:5000/api/member/auth/profile)

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
        "created_at": "2026-09-05T...",
        "updated_at": "2026-09-05T..."
    }
}



ADMIN Side 

[POST /api/admin/auth/login](http://localhost:5000/api/admin/auth/login)

request = {
    "email": "admin@gym.com",
    "password": "Admin@123"
}
response = {
    "success": true,
    "message": "Admin login successful",
    "token": "JWT_TOKEN_HERE",
    "admin": {
        "id": 1,
        "name": "Gym Admin",
        "email": "admin@gym.com",
        "role": "ADMIN",
        "phone": "9999999999",
        "status": "ACTIVE"
    }
}

GET = http://localhost:5000/api/admin/auth/profile
response = {
    "success": true,
    "message": "Admin profile fetched successfully",
    "admin": {
        "id": 1,
        "name": "Gym Admin",
        "email": "admin@gym.com",
        "role": "ADMIN",
        "phone": "9999999999",
        "status": "ACTIVE",
        "created_at": "2026-09-05T...",
        "updated_at": "2026-09-05T..."
    }
}

POST : http://localhost:5000/api/admin/trainers
request = {
    "name": "Arun Kumar",
    "email": "arun@gym.com",
    "phone": "9876543210",
    "password": "Trainer@123"
}

response = {
    "success": true,
    "message": "Trainer created successfully",
    "trainer": {
        "id": 3,
        "name": "Arun Kumar",
        "email": "arun@gym.com",
        "phone": "9876543210",
        "role": "TRAINER",
        "status": "ACTIVE"
    }
}

Trainer side 

POST => http://localhost:5000/api/trainer/auth/login
request = {
    "email": "arun@gym.com",
    "password": "Trainer@123"
}

response = {
    "success": true,
    "message": "Trainer login successful",
    "token": "JWT_TOKEN_HERE",
    "trainer": {
        "id": 3,
        "name": "Arun Kumar",
        "email": "arun@gym.com",
        "role": "TRAINER",
        "phone": "9876543210",
        "status": "ACTIVE"
    }
}

GET /api/trainer/auth/profile
response = {
    "success": true,
    "message": "Trainer profile fetched successfully",
    "trainer": {
        "id": 3,
        "name": "Arun Kumar",
        "email": "arun@gym.com",
        "role": "TRAINER",
        "phone": "9876543210",
        "status": "ACTIVE",
        "created_at": "2026-09-05T...",
        "updated_at": "2026-09-05T..."
    }
}
