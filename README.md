# Questora

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue?style=for-the-badge&logo=android&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.5+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Backend-Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Local_DB-SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License" />
</p>

---

## Overview

**Questora** is a high-performance, offline-first mobile examination and practice platform engineered for Bangladeshi HSC and university admission candidates. Built with Flutter, Riverpod, SQLite, and Supabase, Questora provides high-speed MCQ practice, realistic timed exam simulations, mathematical equation rendering, and data-driven diagnostic performance analytics.

---

## Key Features

### 1. High-Speed Question Bank & Practice Engine
* **Subject & Paper Browsing:** Explore questions organized hierarchically across subjects (Physics, Chemistry, Higher Math, Biology, Bangla, English, ICT) and individual papers.
* **Chapter & Topic Breakdown:** Drill down into specific syllabus chapters and granular sub-topics for targeted revision.
* **Board & Year-Wise Filtering:** Practice past question papers categorized by education boards (Dhaka, Chittagong, Rajshahi, Comilla, Sylhet, Barisal, Jessore, Dinajpur, Mymensingh) and specific examination years.
* **Instant Answer Validation:** Immediate verification of submitted answers with comprehensive explanation modals.
* **Question Bookmarking:** Save challenging questions with one-tap bookmarking for subsequent review in a dedicated Saved Questions hub.

### 2. Timed Mock Exam Simulation
* **Configurable Exam Parameters:** Select question quantities (10, 20, 30, 40, or custom) and time limits (10, 20, 30, 45 minutes, or custom).
* **Subject-Specific or Mixed Mock Tests:** Attempt targeted single-subject exams or full-syllabus multi-subject tests simulating real admission entrance exams.
* **Active Countdown Timer:** Live synchronized timer with auto-submission on expiration.
* **Submission Safety:** Protective confirmation modals prevent unintended submissions during active sessions.

### 3. Exam Scorecard & Answer Review
* **Instant Score Computation:** Real-time scoring factoring in negative marking policies.
* **Visual Analytics Breakdown:** Interactive donut charts visualizing the ratio of correct, incorrect, and skipped questions.
* **Question-by-Question Solution Review:** Complete post-exam walkthrough detailing correct answers, user choices, and pedagogical explanations.

### 4. Diagnostic Analytics & Learning Telemetry
* **Overall Accuracy Telemetry:** Cumulative accuracy percentages, attempt counts, and correct vs. wrong ratios.
* **Streak & Habit Tracking:** Daily practice continuity tracking to reinforce consistent study habits.
* **Topic-Level Diagnostic Breakdown:** Automated identification of strong versus weak syllabus topics using color-graded performance thresholds.
* **Mock Exam History:** Chronological historical records tracking scores, test durations, and progression curves over time.

### 5. Mathematical & Scientific Notation Support
* **TeX / LaTeX Equation Rendering:** Crisp, scalable mathematical equations, matrices, and scientific notation rendered via `flutter_math_fork`.
* **HTML Content Formatting:** Native rendering of sub/superscripts, chemical formulas, and structured text passages through `flutter_html`.

### 6. Offline-First Architecture
* **SQLite Local Caching:** Local persistent database storing attempt histories, quiz states, and streaks without network dependency.
* **Zero-Latency Interaction:** Smooth offline user experience ensuring students can practice in low-bandwidth or disconnected environments.

### 7. Authentication & User Profile
* **Supabase Authentication:** Secure cloud authentication supporting Email/Password and Google OAuth.
* **Academic Profiling:** Configurable stream selection (HSC, SSC, Medical Admission, Engineering Admission) and academic track (Science, Commerce, Humanities).
* **Settings & Preferences:** Notification preference toggles, password updates, and support resources.

---

## Technology Stack

<p align="left">
  <img src="https://img.shields.io/badge/Flutter-Framework-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Riverpod-State_Management-2E8555?style=flat-square&logo=riverpod&logoColor=white" alt="Riverpod" />
  <img src="https://img.shields.io/badge/Supabase-Backend_&_Auth-3ECF8E?style=flat-square&logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/SQLite-Local_Storage-003B57?style=flat-square&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/FL_Chart-Visualization-FF6F00?style=flat-square" alt="FL Chart" />
  <img src="https://img.shields.io/badge/PostgreSQL-Database-4169E1?style=flat-square&logo=postgresql&logoColor=white" alt="PostgreSQL" />
</p>

* **Frontend Framework:** Flutter (Dart SDK `^3.11.0`)
* **State Architecture:** Riverpod with Code Generation (`riverpod_annotation`, `riverpod_generator`)
* **Backend Platform:** Supabase (PostgreSQL, Row-Level Security, Auth)
* **Local Persistence:** `sqflite`, `shared_preferences`
* **Data Visualization:** `fl_chart`
* **Equation & Markup Rendering:** `flutter_math_fork`, `flutter_html`
* **Typography:** `google_fonts` (Inter / Roboto)

---

## Project Structure

```text
lib/
|-- core/
|   |-- database/           # SQLite persistence helper (LocalProgressDb)
|   +-- theme/              # Color palette (AppColors) and global ThemeData
|-- features/
|   |-- auth/               # Supabase authentication and state
|   |-- exam/               # Mock exam configuration, countdown engine, scorecard
|   |-- home/               # Dashboard, banner carousels, quick action grid
|   |-- practice/           # Question bank, board/year filters, analytics, LaTeX view
|   |-- profile/            # Academic info, profile settings, credential management
|   +-- startup/            # Animated splash screen and onboarding walkthrough
+-- shared/
    +-- widgets/            # Reusable buttons, error boundaries, state displays
```

---

## Getting Started

### Prerequisites
* Flutter SDK (Version 3.24.0 or newer)
* Dart SDK (Version 3.5.0 or newer)
* Android SDK / Xcode for platform compilation
* Configured Supabase project with tables deployed from `supabase_schema.sql`

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/motiurfarazi/questora.git
   cd questora
   ```

2. **Install project dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   You can run the app with custom Supabase credentials via Dart define flags:
   ```bash
   flutter run --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_KEY
   ```

4. **Execute Code Generation:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the Application:**
   ```bash
   flutter run
   ```

---

## Testing & Quality Assurance

To execute the unit and widget test suite:
```bash
flutter test
```

To run static analysis:
```bash
flutter analyze
```

---

## Developer Credits

<p align="left">
  <img src="https://img.shields.io/badge/Lead_Developer-Motiur_Farazi-1E3A8A?style=for-the-badge&logo=github&logoColor=white" alt="Motiur Farazi" />
</p>

* **Lead Architect & Developer:** **Motiur Farazi**
* **GitHub Profile:** [@motiurfarazi](https://github.com/motiurfarazi)
* **Email Contact:** [motiurfarazi@users.noreply.github.com](mailto:motiurfarazi@users.noreply.github.com)
* **Project Role:** System Architecture, Flutter Mobile Engineering, Database Design & UI Implementation

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
