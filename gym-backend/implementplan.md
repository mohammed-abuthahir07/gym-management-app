PeakForge Gym Management System - Flutter Frontend Implementation Plan
Build a complete, responsive Flutter frontend for the PeakForge Gym Management System inside the existing gym_frontend project. The application connects directly to the existing Express + MySQL backend without altering backend code, and seamlessly supports both Windows desktop and Android mobile with a single shared codebase and centralized theme customizer.

User Review Required
IMPORTANT

Backend Integrity: All backend code in gym-backend remains untouched.
Authentication & Ownership: Member & trainer IDs are never manually inputted where the backend infers identity from JWT tokens.
Static vs API Pages: Static content is strictly limited to Home and Location; all other modules (Pricing, Promotions, Gallery, Trainers, Contact, Auth, Member, Trainer, Admin) strictly consume the live backend endpoints.
Theming: Powered by AppTheme, AppPalettes (6 color themes), and ThemeController with light/dark/system modes persisted via SharedPreferences.
Proposed Architecture & File Structure

lib/
├── main.dart                                    # MultiProvider root, routes, theme listener
├── config/
│   └── api_config.dart                          # Dynamic base URL (Windows / Emulator / LAN)
├── services/
│   ├── api_service.dart                         # HTTP client with JWT interceptor & error handling
│   └── storage_service.dart                     # SharedPreferences session & token persistence
├── theme/
│   ├── app_colors.dart                          # AppPalette definitions (PeakForge, Blue, Green, etc.)
│   ├── app_theme.dart                           # Material 3 light/dark ThemeData builder
│   └── theme_controller.dart                    # ThemeMode & AppPalette state with local persistence
├── utils/
│   ├── constants.dart                           # App names, static address/hours, storage keys
│   ├── json_helpers.dart                        # Safe parsing utilities for Maps, Lists, Numbers
│   ├── responsive.dart                          # Responsive breakpoints (Mobile, Tablet, Desktop)
│   └── validators.dart                          # Email, phone, password, positive numbers validation
├── widgets/
│   └── common/
│       ├── app_shell.dart                       # Adaptive shell (NavigationRail on desktop, Drawer/NavBar on mobile)
│       ├── app_widgets.dart                     # AppButton, StatCard, StatusBadge, AsyncStateView, NetworkImageSafe
│       └── theme_settings.dart                  # Modal dialog for changing ThemeMode and Palette
├── controllers/
│   └── auth/
│       └── auth_controller.dart                 # Login, Register, Logout, Token lifecycle
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart                    # Common login screen (Member, Trainer, Admin)
│   │   └── register_screen.dart                 # Member registration screen
│   ├── public/
│   │   ├── public_shell.dart                    # Public tab navigation shell
│   │   ├── home_page.dart                       # PeakForge landing page (Hero, Benefits, CTA)
│   │   ├── pricing_page.dart                    # Live GET /api/plans pricing cards
│   │   ├── promotions_page.dart                 # Live GET /api/promotions deals
│   │   ├── gallery_page.dart                    # Live GET /api/content responsive image gallery
│   │   ├── trainers_page.dart                   # Live GET /api/trainers public list
│   │   ├── location_page.dart                   # PeakForge Madurai gym location & timing details
│   │   └── contact_page.dart                    # Live POST /api/contact guest enquiry form
│   ├── member/
│   │   ├── member_shell.dart                    # Member navigation shell with responsive rail/drawer
│   │   ├── member_dashboard_page.dart           # Live dashboard statistics, today's workout & diet
│   │   ├── member_workout_page.dart             # Assigned workout plans & exercise completion
│   │   ├── member_exercises_page.dart           # Exercise library with filter/search
│   │   ├── member_diet_page.dart                # Today's diet & assigned meal plans
│   │   ├── member_cheat_days_page.dart          # Member cheat day logging (CRUD)
│   │   ├── member_progress_page.dart            # Body progress tracking (weight, waist, fat % CRUD)
│   │   ├── member_challenges_page.dart          # Active challenges & rewards
│   │   ├── member_notifications_page.dart       # Live notifications list with mark-as-read
│   │   ├── member_chat_page.dart                # Chat messaging with assigned trainer
│   │   ├── member_analytics_page.dart           # Checkins, cheat meals, month progress, payment status
│   │   ├── member_fees_page.dart                # Fee payment status & history
│   │   └── member_profile_page.dart             # Member physical profile view/edit
│   ├── trainer/
│   │   ├── trainer_shell.dart                   # Trainer navigation shell
│   │   ├── trainer_dashboard_page.dart          # Assigned members count, diet plans count, check-ins
│   │   ├── trainer_members_page.dart            # Assigned members list & detailed member inspection
│   │   ├── trainer_workout_plans_page.dart      # Workout plan builder & exercise assignment (CRUD)
│   │   ├── trainer_diet_plans_page.dart         # Diet plan creator & manager for assigned members (CRUD)
│   │   ├── trainer_classes_page.dart            # Class schedule planner (HIIT, strength, etc.) (CRUD)
│   │   ├── trainer_cheat_days_page.dart         # Member cheat day monitoring (current/previous month)
│   │   ├── trainer_analytics_page.dart          # Today's workouts progress tracking
│   │   ├── trainer_chat_page.dart               # Trainer-to-member conversations
│   │   └── trainer_profile_page.dart            # Trainer profile details
│   └── admin/
│       ├── admin_shell.dart                     # Admin navigation shell
│       ├── admin_dashboard_page.dart            # Multi-metric dashboard & recent entities
│       ├── admin_members_page.dart              # Member management, trainer assignment & unassignment
│       ├── admin_trainers_page.dart             # Trainer creation, directory & deletion
│       ├── admin_plans_page.dart                # Membership plan creator & pricing manager (CRUD)
│       ├── admin_promotions_page.dart           # Discount & promotional codes manager (CRUD)
│       ├── admin_challenges_page.dart           # Gym challenges manager (CRUD)
│       ├── admin_exercises_page.dart            # Gym exercise database manager (CRUD)
│       ├── admin_content_page.dart              # Gallery & marketing content manager (Multipart file upload)
│       ├── admin_fees_page.dart                 # Fee records, payment logs & monthly status
│       ├── admin_contacts_page.dart             # Inbound visitor enquiries reader & deletion
│       ├── admin_notifications_page.dart        # Push broadcasts to members/trainers/individuals
│       ├── admin_reports_page.dart              # Financial revenue, check-in totals & unpaid dues
│       └── admin_profile_page.dart              # Admin credentials & profile
Detailed Screen-to-API Mapping
1. Public Endpoints (No JWT)
Home: Static landing page. Hero banner, benefits, highlights, CTAs.
Location: Static gym address (Madurai, Tamil Nadu), opening hours, phone, email.
Pricing: GET /api/plans
Promotions: GET /api/promotions
Gallery: GET /api/content
Trainers: GET /api/trainers
Contact: POST /api/contact with { name, email, phone, message }
Login:
Member: POST /api/member/auth/login
Trainer: POST /api/trainer/auth/login
Admin: POST /api/admin/auth/login
Register: POST /api/member/auth/register
2. Member Endpoints (Bearer JWT)
Dashboard:
GET /api/member/dashboard/checkin-days
GET /api/member/dashboard/cheat-count
GET /api/member/dashboard/diet-plan
GET /api/member/dashboard/workout-plans
GET /api/member/dashboard/notifications
GET /api/member/dashboard/previous-month-progress
GET /api/member/dashboard/today-workout
Workout Plans:
GET /api/member/workout-plans
GET /api/member/workout-plans/:id
POST /api/member/workout-plans/:planId/exercises/:workoutExerciseId/complete
Exercises: GET /api/member/exercises
Diet:
GET /api/member/diet-plans/today
GET /api/member/diet-plans
GET /api/member/diet-plans/:id
Cheat Days:
GET /api/member/cheat-days
POST /api/member/cheat-days
PUT /api/member/cheat-days/:id
DELETE /api/member/cheat-days/:id
Progress:
GET /api/member/progress
POST /api/member/progress
PUT /api/member/progress/:id
DELETE /api/member/progress/:id
Challenges: GET /api/member/challenges
Notifications:
GET /api/member/notifications
PUT /api/member/notifications/:id/read
Trainer Chat:
GET /api/member/messages/trainer
GET /api/member/messages/:trainerId
POST /api/member/messages/:trainerId
PUT /api/member/messages/:id/read
Analytics & Fees:
GET /api/member/analytics/current-month-checkin-days
GET /api/member/analytics/current-month-payment-status
GET /api/member/analytics/tomorrow-workout
GET /api/member/analytics/current-month-cheat-meals
GET /api/member/analytics/current-month-progress
GET /api/member/fees
GET /api/member/fees/current-month/paid-status
GET /api/member/fees/paid-history
Profile:
GET /api/member/profile (fallback to /api/member/auth/profile)
POST /api/member/profile / PUT /api/member/profile
3. Trainer Endpoints (Bearer JWT)
Dashboard:
GET /api/trainer/dashboard/assigned-members
GET /api/trainer/dashboard/diet-plans
GET /api/trainer/dashboard/workout-plans
GET /api/trainer/dashboard/check-ins
Assigned Members:
GET /api/trainer/assigned-members
GET /api/trainer/assigned-members/:id
Workout Plans:
GET /api/trainer/workout-plans
POST /api/trainer/workout-plans
GET /api/trainer/workout-plans/:id
PUT /api/trainer/workout-plans/:id
DELETE /api/trainer/workout-plans/:id
POST /api/trainer/workout-plans/:id/exercises
PUT /api/trainer/workout-plans/:planId/exercises/:workoutExerciseId
DELETE /api/trainer/workout-plans/:planId/exercises/:workoutExerciseId
Diet Plans:
GET /api/trainer/diet-plans
POST /api/trainer/diet-plans
GET /api/trainer/diet-plans/:id
PUT /api/trainer/diet-plans/:id
DELETE /api/trainer/diet-plans/:id
Class Schedules:
GET /api/trainer/class-schedules
POST /api/trainer/class-schedules
PUT /api/trainer/class-schedules/:id
DELETE /api/trainer/class-schedules/:id
Cheat Day Monitoring:
GET /api/trainer/cheat-days/members
GET /api/trainer/cheat-days/current-month
GET /api/trainer/cheat-days/previous-month
GET /api/trainer/cheat-days/members/:memberId
Analytics: GET /api/trainer/analytics/today-workouts
Chat:
GET /api/trainer/messages
GET /api/trainer/messages/:memberId
POST /api/trainer/messages/:memberId
PUT /api/trainer/messages/:id/read
Profile: GET /api/trainer/auth/profile
4. Admin Endpoints (Bearer JWT)
Dashboard & Revenue:
GET /api/admin/dashboard/member
GET /api/admin/dashboard/trainer
GET /api/admin/dashboard/plan
GET /api/admin/dashboard/promotion
GET /api/admin/dashboard/challenge
GET /api/admin/dashboard/recent/plan
GET /api/admin/dashboard/recent/promotion
GET /api/admin/dashboard/recent/challenge
GET /api/admin/dashboard/current-month-revenue
GET /api/admin/dashboard/current-year-revenue
GET /api/admin/dashboard/total-revenue
Members:
GET /api/admin/members
GET /api/admin/members/:id
DELETE /api/admin/members/:id
PUT /api/admin/members/:id/trainer
DELETE /api/admin/members/:id/trainer
Trainers:
GET /api/admin/trainers
POST /api/admin/trainers
GET /api/admin/trainers/:id
DELETE /api/admin/trainers/:id
Plans (Admin CRUD):
GET /api/admin/plans
POST /api/admin/plans
GET /api/admin/plans/:id
Promotions (Admin CRUD):
GET /api/admin/promotions
POST /api/admin/promotions
PUT /api/admin/promotions/:id
DELETE /api/admin/promotions/:id
Challenges (Admin CRUD):
GET /api/admin/challenges
POST /api/admin/challenges
PUT /api/admin/challenges/:id
DELETE /api/admin/challenges/:id
Exercises (Admin CRUD):
GET /api/admin/exercises
POST /api/admin/exercises
PUT /api/admin/exercises/:id
DELETE /api/admin/exercises/:id
Content (Admin CRUD):
GET /api/admin/content
POST /api/admin/content (multipart file)
PUT /api/admin/content/:id
DELETE /api/admin/content/:id
Fees:
GET /api/admin/fees
POST /api/admin/fees
GET /api/admin/fees/current-month
GET /api/admin/fees/member/:memberId
PUT /api/admin/fees/:id
DELETE /api/admin/fees/:id
Contacts:
GET /api/admin/contacts
GET /api/admin/contacts/:id
DELETE /api/admin/contacts/:id
Notifications:
GET /api/admin/notifications
POST /api/admin/notifications/members
POST /api/admin/notifications/trainers
POST /api/admin/notifications/member/:id
POST /api/admin/notifications/trainer/:id
Reports & Analytics:
GET /api/admin/report/current-month-revenue
GET /api/admin/report/current-year-revenue
GET /api/admin/report/total-revenue
GET /api/admin/report/current-month-checkins
GET /api/admin/report/current-year-checkins
GET /api/admin/report/current-month-unpaid
GET /api/admin/analytics/member
GET /api/admin/analytics/trainer
GET /api/admin/analytics/plan
GET /api/admin/analytics/promotion
GET /api/admin/analytics/challenge
Profile: GET /api/admin/auth/profile
Step-by-Step Implementation Sequence
Step 1: Public Module
Implement home_page.dart with hero banner, gym values, fitness perks, and CTAs.
Implement pricing_page.dart dynamically querying GET /api/plans.
Implement promotions_page.dart querying GET /api/promotions.
Implement gallery_page.dart querying GET /api/content with NetworkImageSafe.
Implement trainers_page.dart querying GET /api/trainers.
Implement location_page.dart with PeakForge Madurai address and schedule.
Implement contact_page.dart querying POST /api/contact.
Step 2: App Entry & Navigation Setup (lib/main.dart)
Update lib/main.dart with providers (StorageService, ApiService, AuthController, ThemeController).
Wire named routes for /, /login, /register, /member, /trainer, /admin.
Connect dynamic Material theme with AppTheme and ThemeController.
Step 3: Member Module
Create member_shell.dart with responsive navigation.
Implement member_dashboard_page.dart (7 statistics APIs).
Implement member_workout_page.dart (workout plans & completion API).
Implement member_exercises_page.dart, member_diet_page.dart, member_cheat_days_page.dart, member_progress_page.dart.
Implement member_challenges_page.dart, member_notifications_page.dart, member_chat_page.dart, member_analytics_page.dart, member_fees_page.dart, and member_profile_page.dart.
Step 4: Trainer Module
Create trainer_shell.dart with responsive navigation.
Implement trainer_dashboard_page.dart (assigned members, diets, workouts, checkins).
Implement trainer_members_page.dart, trainer_workout_plans_page.dart (CRUD + exercise addition), trainer_diet_plans_page.dart (CRUD).
Implement trainer_classes_page.dart (CRUD), trainer_cheat_days_page.dart (current/previous month monitoring), trainer_analytics_page.dart, trainer_chat_page.dart, and trainer_profile_page.dart.
Step 5: Admin Module
Create admin_shell.dart with responsive sidebar/navigation.
Implement admin_dashboard_page.dart (counts, recent items, revenues).
Implement admin_members_page.dart (member listing, assign/remove trainer, delete).
Implement admin_trainers_page.dart (create trainer with password, view, delete).
Implement admin_plans_page.dart (CRUD), admin_promotions_page.dart (CRUD), admin_challenges_page.dart (CRUD), admin_exercises_page.dart (CRUD).
Implement admin_content_page.dart (file picker multipart upload + delete).
Implement admin_fees_page.dart (fee recording and status), admin_contacts_page.dart (enquiries viewer/delete), admin_notifications_page.dart (broadcast & direct sending), admin_reports_page.dart (financial & attendance cards), and admin_profile_page.dart.
Step 6: Verification & Quality Assurance
Run flutter analyze and resolve any lint or analyzer issues.
Verify Windows execution and responsiveness.
Verification Plan
Automated Tests & Lint
Run flutter analyze inside gym_frontend to guarantee 0 errors and clean code.
Manual Verification
Public Flows: Browse Home, Pricing, Promotions, Gallery, Trainers, Location, and submit guest Contact form.
Authentication: Sign in as Member, Trainer, and Admin; verify routing to respective dashboards.
Theming: Toggle light/dark/system mode and switch between palettes (PeakForge Default, Blue, Green, Purple, Orange, Red) in real-time.
Responsive UI: Validate responsive navigation transitions between desktop sidebar and mobile drawer/bottom navigation.