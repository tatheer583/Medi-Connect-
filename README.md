# 🏥 MediConnectSmart

**AI-powered Healthcare Management Platform for Pakistan & South Asia**

MediConnectSmart bridges the gap between doctors, clinics, and patients through a single unified mobile application — powered by an intelligent AI Agent that automates scheduling, reminders, and clinical summaries.

---

## 📱 Download APK

> ⬇️ **[Download Latest APK](https://github.com/tatheer583/Medi-Commit-/releases/latest)** — Install directly on any Android device

---

## ✨ Features

| Feature | Status |
|---|---|
| Doctor & Clinic Registration | ✅ |
| Patient Profile & Health Card | ✅ |
| Appointment Booking System | ✅ |
| Digital Prescription Generator | ✅ |
| Medicine Reminders (AI) | ✅ |
| Doctor–Patient In-App Chat | ✅ |
| Lab Test Results Upload | ✅ |
| AI Pre-Appointment Summary | ✅ |
| Multi-Language (Urdu/English) | ✅ |

---

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Android & iOS) |
| Backend API | Node.js + Express + TypeScript |
| Database & Auth | Appwrite BaaS |
| AI Engine | Claude API (Anthropic) |
| Push Notifications | Firebase Cloud Messaging |

---

## 🚀 Getting Started

### Backend

```bash
cd backend-node
cp .env.example .env
# Fill in your Appwrite and JWT credentials in .env
npm install
npm run dev
```

### Mobile App

```bash
cd mobile
flutter pub get
flutter run
```

### Build Release APK

```bash
cd mobile
flutter build apk --release
# APK output: mobile/build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Project Structure

```
MediConnect/
├── backend-node/        # Node.js/Express REST API
│   ├── src/
│   │   ├── controllers/ # Route handlers
│   │   ├── services/    # Business logic
│   │   ├── models/      # TypeScript interfaces
│   │   ├── routes/      # Express routes
│   │   ├── middleware/  # Auth, error handling
│   │   └── validators/  # Joi validation schemas
├── mobile/              # Flutter mobile app
│   └── lib/
│       └── src/
│           ├── features/    # App features (auth, appointments, etc.)
│           ├── routing/     # App navigation
│           ├── services/    # API service layer
│           └── theme/       # App theming
├── mobile-rn/           # React Native app (scaffold)
├── releases/            # Built APK files
└── docker-compose.yml   # Local development stack
```

---

## 🔐 Environment Variables

Copy `backend-node/.env.example` to `backend-node/.env` and fill in:

```
APPWRITE_PROJECT_ID=your_project_id
APPWRITE_API_KEY=your_api_key
JWT_SECRET=your_jwt_secret
CLAUDE_API_KEY=your_claude_api_key
```

---

## 👨‍⚕️ User Roles

- **Doctor** — Manage patients, write prescriptions, view AI summaries
- **Patient** — Book appointments, track medications, view health card
- **Lab Technician** — Upload test results

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.
