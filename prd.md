# 📋 Questora — Product Requirements & Architecture Document

**Application Name:** Questora  
**Domain:** EdTech (HSC & University Admission Exam Preparation)  
**Target Platform:** Flutter (Android & iOS)  
**Backend:** Supabase (PostgreSQL, Auth, Storage)  

---

## 1. Product Overview

Questora is a high-performance MCQ practice and exam simulation platform tailored for Bangladeshi HSC and university admission examinees. The core value proposition centers around fast question practice, realistic timed exam simulations, and deep offline-first performance analytics.

### 1.1 Core Pillars
* **High-Speed Practice Engine:** Chapter, topic, and board-wise question navigation with instant verification.
* **Timed Exam Simulation:** Strict countdown timer, negative marking calculations, and structured post-exam reviews.
* **Intelligent Performance Telemetry:** Weak-topic identification, subject accuracy metrics, and daily practice consistency tracking.
* **Offline-First Persistence:** SQLite database caching attempt logs and streak metrics locally without requiring active network connectivity.

---

## 2. Technical Architecture

### 2.1 Frontend Architecture
* **Framework:** Flutter 3.24+ / Dart SDK ^3.11.0
* **State Management:** Riverpod 2.x/3.x with code generation (`@riverpod`, `riverpod_generator`)
* **Mathematical Notation:** TeX / LaTeX formula parsing powered by `flutter_math_fork` and `flutter_html`
* **Local Storage:** `sqflite` for relational attempt logging, `shared_preferences` for key-value configuration
* **Data Visualization:** `fl_chart` for progress charts, historical accuracy curves, and score breakdown donuts

### 2.2 Backend & Data Storage
* **Database:** Supabase PostgreSQL with Row Level Security (RLS)
* **Authentication:** Supabase Auth (Email/Password, Google Sign-In)
* **API Interface:** Supabase Flutter SDK

---

## 3. Database Schema Overview

### Core Tables
1. **`subjects`**: Subject registry (e.g., Physics, Chemistry, Higher Math) mapped to exam types (`hsc`, `admission`) and group streams (`science`, `commerce`, `arts`).
2. **`chapters`**: Sequential chapter units linked to subject entities with ordering indexes.
3. **`topics`**: Granular topic sub-divisions for targeted diagnostic practice.
4. **`questions`**: MCQ repository containing question text (HTML/TeX), 4 option choices, correct answer, explanation payload, board provenance, and publication year.
5. **`profiles`**: User metadata, active exam target, and streak counters.
6. **`bookmarks`**: User question bookmark relations.

---

## 4. UI/UX Design System

### 4.1 Color Palette
* **Primary Deep Blue:** `#1E3A8A`
* **Accent Royal Blue:** `#2563EB`
* **Success Green:** `#16A34A`
* **Error Crimson:** `#DC2626`
* **Background Light Canvas:** `#F8FAFC`
* **Card Surface:** `#FFFFFF`
* **Border Neutral:** `#E2E8F0`

### 4.2 Typography & Spacing
* **Font Family:** Google Fonts (Inter / Roboto / Hind Siliguri)
* **Layout Grid:** 8pt modular grid with 12px, 16px, and 20px card corner radiuses.

---

## 5. Development Roadmap & Milestones

- [x] Phase 1: Core Question Engine & Math Rendering
- [x] Phase 2: Offline SQLite Local Progress Tracking
- [x] Phase 3: Timed Exam Simulation Engine & Review Mode
- [x] Phase 4: Performance Analytics & Charts Dashboard
- [ ] Phase 5: Cloud Synchronization for Multi-Device Progress
- [ ] Phase 6: Collaborative Leaderboards & Realtime Contests
