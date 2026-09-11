# 🎓 AI Student Assistant

An AI-powered productivity app for college students — built with Flutter, Firebase, and the Gemini API, following Clean Architecture principles. Built as a Flutter internship portfolio project.

## ✨ Features

- **Authentication** — Email/password + Google Sign-In, with a profile setup flow for college/course details
- **AI Study Assistant** — Chat with an AI tutor, summarize notes, generate quizzes, get study recommendations (Gemini API)
- **Smart Notes** — Create/edit/delete notes, attach PDFs/images, one-tap AI summarization, local search
- **Task & Assignment Manager** — Priorities, deadlines, completion tracking, Firestore real-time sync
- **Study Planner** — Weekly calendar view, session tracking, productivity bar chart
- **Campus Feed** — Read-only announcements/events stream
- **Dashboard** — Today's tasks, upcoming deadlines, AI suggestion card, quick actions, stats

## 🏗️ Architecture

This app follows **Clean Architecture** with a **feature-first** folder structure, and **Riverpod** for state management.

```
Presentation (UI + Riverpod providers)
        ↓ depends on
   Domain (Entities, Repository interfaces, Usecases)  ← pure Dart, zero Flutter/Firebase imports
        ↑ implemented by
     Data (Models, Datasources, Repository implementations)  ← talks to Firebase/REST APIs
```

**Why this matters:** the `domain` layer never imports `cloud_firestore`, `dio`, or any Flutter widget. Every repository is an abstract interface in `domain/repositories/`, implemented concretely in `data/repositories/`. This means:
- The UI layer never talks to Firebase directly — it goes through a usecase → repository interface.
- You could swap Firestore for a REST backend by only touching the `data/` folder.
- Every usecase is trivially unit-testable with a mock repository (see `test/`).

See `lib/features/` — each feature (`auth`, `notes`, `tasks`, `ai_assistant`, `study_planner`, `campus`, `dashboard`) has its own `data/`, `domain/`, `presentation/` subfolders. `lib/core/` holds cross-cutting concerns (theme, shared widgets, error types, utils) used by every feature.

## 📦 Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3.3+ / Dart 3 |
| State management | Riverpod (`flutter_riverpod`) |
| Routing | `go_router` (with auth-aware redirects + bottom-nav shell route) |
| Backend | Firebase (Auth, Firestore, Storage, Cloud Messaging) |
| AI | Google Gemini API (`gemini-1.5-flash`) via REST |
| Networking | `dio` |
| Charts | `fl_chart` |
| Calendar | `table_calendar` |

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK 3.3+ installed (`flutter doctor` should pass)
- A Firebase account
- A Gemini API key ([aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)) — free tier is enough for a demo

### 2. Clone & install dependencies
```bash
cd ai_student_assistant
flutter pub get
```

### 3. Set up your API keys
```bash
cp .env.example .env
```
Open `.env` and paste in your real Gemini API key:
```
GEMINI_API_KEY=AIza...your_real_key...
```
**`.env` is already in `.gitignore` — never commit it.**

### 4. Firebase Setup

1. Go to the [Firebase Console](https://console.firebase.google.com) → **Add project** → name it (e.g. `ai-student-assistant`).
2. **Authentication** → Sign-in method → enable **Email/Password** and **Google**.
3. **Firestore Database** → Create database → start in test mode (we'll apply the provided security rules next).
4. **Storage** → Get started (used for note PDF/image uploads).
5. **Cloud Messaging** → already enabled by default once the project exists.
6. Install the FlutterFire CLI and generate `firebase_options.dart` for your project:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=your-firebase-project-id
   ```
   This overwrites the placeholder `lib/firebase_options.dart` with real config and registers your Android/iOS/web apps automatically.
7. Deploy the included security rules (in the project root):
   ```bash
   firebase deploy --only firestore:rules,storage
   ```
   `firestore.rules` and `storage.rules` restrict every read/write to the signed-in user's own data — review them before shipping.

### 5. Run the app
```bash
flutter run
```

## 🔑 Where API Keys Go (Security Notes)

- **Gemini/OpenAI keys** live in `.env` (gitignored) and are read exclusively through `lib/config/env/env.dart`. Never call `dotenv.env[...]` anywhere else in the codebase — always go through `Env.geminiApiKey`.
- **Firebase config** (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) is also gitignored, since it contains project identifiers. Regenerate it locally via `flutterfire configure`.
- **For a real production release**, don't ship the raw Gemini key inside the compiled app binary at all — proxy AI calls through a **Firebase Cloud Function** that holds the key server-side (the client calls your function, your function calls Gemini). Because `AiRemoteDataSource` in `lib/features/ai_assistant/data/datasources/ai_remote_datasource.dart` sits behind the `AiRepository` interface, swapping to a proxy only requires editing that one file — nothing else in the app needs to change. This is flagged with a comment directly in that file.

## 🧪 Testing

Sample unit tests are included in `test/` demonstrating the Clean Architecture testing pattern — mocking a repository interface and testing a usecase in isolation, with zero Firebase/Flutter dependencies:

```bash
flutter test
```

See `test/features/auth/sign_in_usecase_test.dart` and `test/features/tasks/toggle_complete_usecase_test.dart` for the pattern — extend it to cover `notes` and `ai_assistant` usecases the same way.

## 📱 Building for Release

**Android (APK for sharing / testing):**
```bash
flutter build apk --release
```

**Android (App Bundle for Play Store):**
```bash
flutter build appbundle --release
```

**iOS (requires a Mac + Xcode):**
```bash
flutter build ios --release
```
Then archive and upload via Xcode, or `flutter build ipa` + Transporter.

Before releasing, double-check:
- [ ] `.env` is populated with your real key locally, but never committed
- [ ] Firestore/Storage security rules are deployed (not left in "test mode")
- [ ] App icons/splash screen configured (`flutter_launcher_icons`, `flutter_native_splash` — not included by default, add if needed)
- [ ] Firebase project is on the Blaze (pay-as-you-go) plan if you expect real traffic — Cloud Messaging + Firestore have generous free tiers otherwise

## 📁 Folder Structure

```
lib/
├── main.dart                  # App entry point, Firebase/env init
├── firebase_options.dart      # Generated by flutterfire configure (gitignored)
├── config/env/                # Env.* — single access point for API keys
├── core/                      # Shared: theme, widgets, utils, error types, router
└── features/
    ├── auth/                  # Login, register, Google sign-in, profile
    ├── dashboard/              # Home tab — tasks/deadlines/AI suggestion summary
    ├── ai_assistant/           # Gemini-powered chat, summarize, quiz generation
    ├── notes/                  # CRUD notes + PDF/image upload + AI summary
    ├── tasks/                  # CRUD tasks with priority/deadline/completion
    ├── study_planner/          # Calendar + session tracking + productivity chart
    ├── campus/                 # Read-only announcements feed
    ├── notifications/          # FCM setup
    └── shell/                  # Bottom-nav shell wrapping the 5 main tabs
```

Each feature folder (except the lightweight ones) follows: `data/{models,datasources,repositories}` → `domain/{entities,repositories,usecases}` → `presentation/{providers,screens,widgets}`.

## 🗺️ Suggested Next Steps (for extending this portfolio project)

- Add `freezed`/`json_serializable` code generation to reduce model boilerplate
- Add offline caching with `hive` or Firestore's built-in offline persistence
- Move AI calls behind a Cloud Function proxy (see security note above)
- Add `flutter_local_notifications` for on-device deadline reminders scheduled ahead of time, independent of FCM push
- Add integration tests with `integration_test` covering the login → create task → complete task flow
