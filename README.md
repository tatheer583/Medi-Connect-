# 🏥 MediConnect Smart

**AI-powered Healthcare Management Platform**

MediConnect Smart is a comprehensive healthcare application that bridges the gap between doctors, clinics, and patients through a unified mobile platform. Powered by OpenAI, it automates appointment scheduling, medicine reminders, and generates intelligent clinical summaries.

---

## 📱 Download APK

> ⬇️ **[Download v1.0.0 APK (50.6 MB)](https://github.com/tatheer583/Medi-Commit-/releases/download/v1.0.0/mediconnect-v1.0.0.apk)** — Install directly on Android 8.0+

**Installation Guide**: See [releases/README.md](releases/README.md) for detailed installation instructions.

---

## ✨ Core Features

### 👨‍⚕️ For Doctors
- ✅ Manage patient appointments
- ✅ Create digital prescriptions with PDF export
- ✅ AI-powered patient summaries before appointments
- ✅ Real-time chat with patients
- ✅ View patient health history and lab results

### 👤 For Patients
- ✅ Search and book appointments with doctors
- ✅ View available time slots
- ✅ Receive and download prescriptions
- ✅ Set medicine reminders with notifications
- ✅ Chat with doctors in real-time
- ✅ Upload and view lab test results
- ✅ Track appointment history

### 🏥 For Clinics
- ✅ Manage clinic information
- ✅ Oversee staff and appointments
- ✅ View clinic analytics

### 🤖 AI Features
- ✅ OpenAI-powered patient summaries
- ✅ Intelligent appointment recommendations
- ✅ Clinical insights for doctors

---

## 🛠️ Tech Stack

| Component | Technology |
|---|---|
| **Mobile App** | Flutter 3.11+ with Riverpod |
| **Backend API** | Node.js + Express + TypeScript |
| **Database** | Appwrite BaaS (Cloud) |
| **Authentication** | JWT + Appwrite Auth |
| **AI Engine** | OpenAI API (GPT-4o-mini) |
| **Real-time** | Appwrite Realtime |
| **Storage** | Appwrite Storage |
| **Notifications** | Flutter Local Notifications |
| **PDF Generation** | PDF library for Dart |
| **UI Framework** | Material Design 3 |
| **State Management** | Riverpod |
| **Routing** | GoRouter |

---

## 📋 System Requirements

### Mobile App
- **Android**: 8.0 (API 26) or higher
- **RAM**: 2 GB minimum (4 GB recommended)
- **Storage**: 51 MB free space
- **Internet**: Required for all features

### Backend
- **Node.js**: 16.0 or higher
- **npm**: 8.0 or higher
- **Appwrite**: Cloud account (free tier available)
- **OpenAI**: API key for AI features

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.11+
- Node.js 16+
- Appwrite account (free at https://cloud.appwrite.io)
- OpenAI API key (https://platform.openai.com/api-keys)

### Backend Setup

```bash
cd backend-node

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Fill in your credentials:
# - APPWRITE_PROJECT_ID
# - APPWRITE_API_KEY
# - APPWRITE_DATABASE_ID
# - OPENAI_API_KEY
# - JWT_SECRET

# Start development server
npm run dev
# Server runs on http://localhost:5000
```

### Mobile App Setup

```bash
cd mobile

# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Appwrite Setup

1. Create account at https://cloud.appwrite.io
2. Create a new project
3. Create database: `mediconnect_db`
4. Create collections:
   - `users` - User profiles
   - `appointments` - Appointment bookings
   - `prescriptions` - Digital prescriptions
   - `chat_messages` - In-app messages
   - `lab_results` - Lab test results
   - `medicine_reminders` - Medicine reminders
   - `doctors` - Doctor profiles
   - `user_profiles` - Extended user info

5. Create storage bucket: `lab_results_files`
6. Set permissions: Allow "any" role for Create, Read, Update, Delete

See [setup_appwrite.ps1](setup_appwrite.ps1) for automated setup script.

---

## 📁 Project Structure

```
MediConnect/
├── mobile/                      # Flutter mobile app (main)
│   ├── lib/
│   │   ├── main.dart           # App entry point
│   │   └── src/
│   │       ├── config/         # Appwrite client config
│   │       ├── features/       # Feature modules
│   │       │   ├── auth/       # Authentication screens
│   │       │   ├── appointments/
│   │       │   ├── prescriptions/
│   │       │   ├── chat/
│   │       │   ├── dashboard/
│   │       │   ├── profile/
│   │       │   └── reminders/
│   │       ├── routing/        # Navigation setup
│   │       ├── services/       # Business logic
│   │       │   ├── ai_service.dart
│   │       │   ├── database_service.dart
│   │       │   ├── auth_service.dart
│   │       │   ├── notification_service.dart
│   │       │   └── pdf_service.dart
│   │       ├── shared/         # Shared widgets
│   │       └── theme/          # App theming
│   ├── pubspec.yaml            # Flutter dependencies
│   └── android/                # Android native code
│
├── backend-node/               # Node.js/Express backend
│   ├── src/
│   │   ├── app.ts             # Express app setup
│   │   ├── config/            # Configuration
│   │   ├── controllers/       # Route handlers
│   │   ├── services/          # Business logic
│   │   ├── models/            # TypeScript interfaces
│   │   ├── routes/            # API routes
│   │   ├── middleware/        # Auth, error handling
│   │   └── validators/        # Input validation
│   ├── package.json           # Node dependencies
│   ├── tsconfig.json          # TypeScript config
│   └── .env                   # Environment variables
│
├── releases/                   # Built APK files
│   ├── mediconnect-v1.0.0.apk # Latest release
│   └── README.md              # Installation guide
│
├── setup_appwrite.ps1         # Automated Appwrite setup
├── create_collections.ps1     # Collection creation script
├── RELEASE_NOTES.md           # Release documentation
├── README.md                  # This file
└── .github/
    └── workflows/
        └── build-apk.yml      # GitHub Actions CI/CD
```

---

## 🔐 Environment Variables

### Backend (.env)

```env
# Server
NODE_ENV=development
PORT=5000

# Appwrite
APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your_project_id
APPWRITE_API_KEY=your_api_key
APPWRITE_DATABASE_ID=mediconnect_db

# JWT
JWT_SECRET=your_jwt_secret_32_chars_min
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=your_refresh_secret_32_chars_min
JWT_REFRESH_EXPIRES_IN=30d

# OpenAI
OPENAI_API_KEY=sk-proj-your_openai_key
OPENAI_MODEL=gpt-4o-mini

# Redis (optional)
REDIS_URL=redis://localhost:6379

# CORS
CORS_ORIGIN=http://localhost:3000

# Logging
LOG_LEVEL=info
```

### Mobile (hardcoded in appwrite_client.dart)

```dart
final Client client = Client()
    .setProject('6a14834f003c65073c46')
    .setEndpoint('https://fra.cloud.appwrite.io/v1');
```

---

## 🔑 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/refresh` - Refresh JWT token
- `POST /api/auth/logout` - Logout user

### Appointments
- `GET /api/appointments` - List appointments
- `POST /api/appointments` - Create appointment
- `PUT /api/appointments/:id` - Update appointment
- `DELETE /api/appointments/:id` - Cancel appointment

### Prescriptions
- `GET /api/prescriptions` - List prescriptions
- `POST /api/prescriptions` - Create prescription
- `GET /api/prescriptions/:id` - Get prescription details

### Chat
- `GET /api/chat/:chatId` - Get chat messages
- `POST /api/chat/:chatId/messages` - Send message

### Lab Results
- `GET /api/lab-results` - List lab results
- `POST /api/lab-results` - Upload lab result
- `GET /api/lab-results/:id` - Get lab result

### AI
- `POST /api/ai/summary` - Generate patient summary

---

## 🧪 Testing

### Run Flutter Tests
```bash
cd mobile
flutter test
```

### Run Backend Tests
```bash
cd backend-node
npm test
```

---

## 📊 Database Schema

### Collections

**users**
- userId (String, 36)
- email (String, 100)
- role (String, 20) - patient/doctor/clinic
- fullName (String, 100)
- phone (String, 20)
- createdAt (String, 50)

**appointments**
- patientId (String, 36)
- doctorId (String, 36)
- date (String, 50)
- timeSlot (String, 20)
- status (String, 20) - pending/confirmed/completed
- notes (String, 500)

**prescriptions**
- doctorId (String, 36)
- patientId (String, 36)
- medicines (String, 2000)
- appointmentId (String, 36)
- createdAt (String, 50)

**chat_messages**
- senderId (String, 36)
- receiverId (String, 36)
- message (String, 1000)
- timestamp (String, 50)
- isRead (Boolean)

**lab_results**
- patientId (String, 36)
- uploadedBy (String, 36)
- testName (String, 100)
- fileUrl (String, 500)
- uploadedAt (String, 50)

---

## 🐛 Troubleshooting

### App won't install
- Ensure Android 8.0 or higher
- Enable "Unknown Sources" in settings
- Check storage space (need 51 MB)

### Cannot login
- Verify internet connection
- Check Appwrite backend is running
- Verify credentials are correct

### Features not working
- Ensure OpenAI API key is valid
- Check Appwrite database permissions
- Verify all collections are created

### Build errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# For backend
npm install
npm run build
```

---

## 📞 Support & Contribution

### Report Issues
- GitHub Issues: https://github.com/tatheer583/Medi-Commit-/issues
- Email: support@mediconnect.app

### Contributing
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Development Guidelines
- Follow Dart/TypeScript style guides
- Write tests for new features
- Update documentation
- Keep commits atomic and descriptive

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Flutter Team** - Amazing mobile framework
- **Appwrite** - Excellent BaaS platform
- **OpenAI** - Powerful AI capabilities
- **Google Fonts** - Beautiful typography
- **Community** - For feedback and support

---

## 📈 Roadmap

### v1.1.0 (Planned)
- [ ] Video consultation support
- [ ] Prescription refill requests
- [ ] Advanced analytics dashboard
- [ ] Multi-language support (Urdu, Arabic)
- [ ] Dark mode theme

### v1.2.0 (Future)
- [ ] Insurance integration
- [ ] Telemedicine features
- [ ] Offline mode
- [ ] Advanced search filters
- [ ] User ratings and reviews

### v2.0.0 (Long-term)
- [ ] Web dashboard for doctors
- [ ] Admin panel
- [ ] Advanced reporting
- [ ] Mobile app for iOS
- [ ] API marketplace

---

**Made with ❤️ by MediConnect Team**

Last Updated: 2026-05-26 | Version: 1.0.0
