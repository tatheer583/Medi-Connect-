<h1 align="center">🏥 MediConnect Smart</h1>

<p align="center">
  <strong>AI-Powered Healthcare Management Platform</strong><br/>
  Built with Flutter · Appwrite · OpenAI
</p>

<p align="center">
  <a href="https://github.com/tatheer583/Medi-Connect-/releases/latest">
    <img src="https://img.shields.io/badge/Download-Latest APK-blue?style=for-the-badge&logo=android" alt="Download APK" />
  </a>
  &nbsp;
  <img src="https://img.shields.io/badge/Flutter-3.29+-02569B?logo=flutter" />
  &nbsp;
  <img src="https://img.shields.io/badge/Appwrite-Cloud-F02E65?logo=appwrite" />
  &nbsp;
  <img src="https://img.shields.io/badge/License-MIT-green" />
</p>

---

## About

MediConnect Smart connects doctors, clinics, and patients in one app. Patients can book appointments, view prescriptions, and manage medicines. Doctors can manage their schedule and write prescriptions. OpenAI generates AI-powered patient summaries before each appointment.

---

## Features

### For Patients
- Book appointments with doctors (search by name or specialty)
- View and download digital prescriptions as PDF
- Set daily medicine reminders with local notifications
- Real-time chat with doctors
- Upload and view lab results
- Personal health dashboard

### For Doctors
- View today's appointment schedule
- Create digital prescriptions
- AI-powered patient summaries before consultations
- Real-time chat with patients

### For Clinics
- Manage clinic profile and staff
- Overview of appointments and activity

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.29+ · Dart · Riverpod · GoRouter |
| Backend | Node.js · Express · TypeScript |
| Database | Appwrite Cloud (BaaS) |
| AI | OpenAI GPT-4o-mini |
| Notifications | Flutter Local Notifications |
| PDF | pdf · printing packages |

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev) 3.29+
- [Node.js](https://nodejs.org) 16+
- [Appwrite Cloud](https://cloud.appwrite.io) account
- OpenAI API key

### Clone
```bash
git clone https://github.com/tatheer583/Medi-Connect-.git
cd Medi-Connect-
```

### Backend
```bash
cd backend-node
cp .env.example .env
# Fill in your Appwrite and OpenAI credentials
npm install
npm run dev
```

### Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

### Appwrite Database Setup
Run the automated setup script:
```powershell
.\setup_appwrite.ps1
```

Or create manually in [Appwrite Console](https://cloud.appwrite.io):
- Database: `mediconnect_db`
- Collections: `appointments`, `prescriptions`, `chat_messages`, `lab_results`, `medicine_reminders`, `doctors`, `user_profiles`
- Storage bucket: `lab_results_files`

---

## Environment Variables

**`backend-node/.env`** (copy from `.env.example`):
```env
APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your_project_id
APPWRITE_API_KEY=your_api_key
APPWRITE_DATABASE_ID=mediconnect_db
OPENAI_API_KEY=your_openai_key
JWT_SECRET=your_jwt_secret
PORT=5000
```

---

## APK Download

The release APK is built automatically via GitHub Actions on every push to `main`.

👉 [Download latest APK](https://github.com/tatheer583/Medi-Connect-/releases/latest)

**Install on Android:**
1. Download the APK
2. Enable *Unknown Sources* in Android settings
3. Tap the APK to install
4. Create an account, select your role, and start using

---

## Project Structure

```
Medi-Connect-/
├── mobile/               # Flutter Android app
│   ├── android/          # Android native config
│   └── lib/
│       └── src/
│           ├── config/   # Appwrite client
│           ├── features/ # Screens (auth, dashboard, chat, etc.)
│           ├── services/ # Appwrite, AI, PDF, notifications
│           ├── shared/   # Reusable widgets
│           └── theme/    # Colors, fonts, theme
├── backend-node/         # Node.js TypeScript API
│   └── src/
│       ├── controllers/
│       ├── services/
│       ├── routes/
│       └── middleware/
├── .github/workflows/    # GitHub Actions (APK build + release)
└── setup_appwrite.ps1    # Automated Appwrite setup
```

---

## Contributing

1. Fork the repo
2. Create a branch: `git checkout -b feature/my-feature`
3. Commit: `git commit -m "Add my feature"`
4. Push: `git push origin feature/my-feature`
5. Open a Pull Request

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

<p align="center">Built with ❤️ by the MediConnect Team</p>
