<div align="center">
  <img src="https://raw.githubusercontent.com/tatheer583/Medi-Connect-/main/mobile/assets/icons/app_icon.png" width="120" alt="MediConnect Logo" onerror="this.src='https://img.icons8.com/fluent/120/000000/stethoscope.png'"/>
  
  <h1>🏥 MediConnect Smart</h1>
  
  <p><strong>Next-Generation Healthcare Management Platform Powered by AI</strong></p>

  <p>
    <a href="https://github.com/tatheer583/Medi-Connect-/actions">
      <img src="https://img.shields.io/github/actions/workflow/status/tatheer583/Medi-Connect-/build.yml?branch=main&style=for-the-badge&logo=github" alt="Build Status" />
    </a>
    <a href="https://github.com/tatheer583/Medi-Connect-/releases/latest">
      <img src="https://img.shields.io/github/v/release/tatheer583/Medi-Connect-?style=for-the-badge&color=blue&logo=android" alt="Latest Release" />
    </a>
    <img src="https://img.shields.io/badge/Flutter-3.29+-02569B?style=for-the-badge&logo=flutter" alt="Flutter Version" />
    <img src="https://img.shields.io/badge/Appwrite-Cloud-F02E65?style=for-the-badge&logo=appwrite" alt="Appwrite" />
  </p>

  <p>
    <a href="#about">About</a> •
    <a href="#key-features">Features</a> •
    <a href="#architecture--tech-stack">Tech Stack</a> •
    <a href="#getting-started">Installation</a> •
    <a href="#contributing">Contributing</a>
  </p>
</div>

---

## 📖 About

**MediConnect Smart** is a comprehensive, AI-driven healthcare platform designed to bridge the gap between patients, medical professionals, and clinics. Built with modern technologies like **Flutter** and **Node.js**, and supercharged by **OpenAI**, MediConnect streamlines medical workflows, enhances patient care, and modernizes clinic operations.

Whether it's booking appointments seamlessly, accessing digital prescriptions, or receiving AI-generated patient summaries before a consultation, MediConnect brings the entire healthcare ecosystem into a single, intuitive application.

---

## ✨ Key Features

### 🧑‍⚕️ For Patients
* **Smart Booking System:** Search for doctors by name, specialty, or clinic and book appointments instantly.
* **Digital Health Records:** Access, view, and securely download digital prescriptions (PDF format) and lab results.
* **Intelligent Reminders:** Set and receive automated, local push notifications for daily medications.
* **Direct Communication:** Real-time, secure messaging with healthcare providers.
* **Personalized Dashboard:** A centralized hub for tracking upcoming appointments, recent prescriptions, and overall health metrics.

### 🩺 For Doctors
* **Schedule Management:** Dynamic daily overview of upcoming appointments and patient queues.
* **AI Patient Summaries:** Leverage OpenAI to generate intelligent pre-consultation summaries based on patient history, enabling better care.
* **Digital Prescriptions:** Easily create, manage, and issue digital prescriptions.
* **Patient Interaction:** Maintain continuous care through secure, real-time patient messaging.

### 🏥 For Clinics
* **Administrative Control:** Manage clinic profiles, operating hours, and staff access.
* **Analytics & Overview:** High-level insights into daily appointments, active doctors, and overall clinic performance.

---

## 🏗 Architecture & Tech Stack

MediConnect employs a scalable, decoupled architecture ensuring robust performance and ease of maintenance.

| Layer | Technologies Used | Purpose |
| :--- | :--- | :--- |
| **Frontend (Mobile)** | `Flutter (3.29+)`, `Dart`, `Riverpod`, `GoRouter` | Cross-platform, high-performance UI and state management. |
| **Backend (API)** | `Node.js`, `Express.js`, `TypeScript` | Secure routing, business logic, and third-party integrations. |
| **Database & Auth** | `Appwrite Cloud` (BaaS) | Secure user authentication, NoSQL data storage, and file storage. |
| **Artificial Intelligence**| `OpenAI GPT-4o-mini` | Processing health data to generate concise patient summaries. |
| **Core Utilities** | `Flutter Local Notifications`, `pdf`, `printing` | Push notifications and dynamic PDF generation. |

---

## 🚀 Getting Started

Follow these instructions to set up the project locally for development and testing.

### Prerequisites

Ensure you have the following installed on your local machine:
* **[Flutter SDK](https://flutter.dev/docs/get-started/install)** (v3.29.0 or higher)
* **[Node.js](https://nodejs.org/en/download/)** (v16.x or higher)
* An active **[Appwrite Cloud](https://cloud.appwrite.io)** account.
* An **OpenAI API Key**.

### 1. Clone the Repository

```bash
git clone https://github.com/tatheer583/Medi-Connect-.git
cd Medi-Connect-
```

### 2. Backend Setup (Node.js)

Navigate to the backend directory and configure the environment:

```bash
cd backend-node
cp .env.example .env
npm install
```

**Configure `backend-node/.env`:**
```env
APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your_project_id
APPWRITE_API_KEY=your_api_key
APPWRITE_DATABASE_ID=mediconnect_db
OPENAI_API_KEY=your_openai_key
JWT_SECRET=your_jwt_secret
PORT=5000
```

Start the development server:
```bash
npm run dev
```

### 3. Database Initialization

We provide a script to automatically structure your Appwrite database. Ensure you are authenticated with the Appwrite CLI or run this via PowerShell:

```powershell
.\setup_appwrite.ps1
```

*(Alternatively, you can manually create the `mediconnect_db` database, associated collections, and the `lab_results_files` storage bucket in the Appwrite Console).*

### 4. Mobile App Setup (Flutter)

Navigate to the mobile application directory, fetch dependencies, and run the app:

```bash
cd ../mobile
flutter pub get
flutter run
```

---

## 📦 Releases & APK Download

We use **GitHub Actions** to automatically build and verify the application on every push to the `main` branch.

**📥 [Download the Latest Release APK](https://github.com/tatheer583/Medi-Connect-/releases/latest)**

### Installation Instructions (Android):
1. Download the `.apk` file to your Android device.
2. Navigate to **Settings > Security** and enable **Install from Unknown Sources**.
3. Open the downloaded file to install MediConnect.
4. Launch the app, register your role, and explore the platform!

---

## 📂 Project Structure

```text
Medi-Connect-/
├── mobile/                  # Flutter Client Application
│   ├── android/             # Android-specific build configurations
│   └── lib/
│       ├── src/
│       │   ├── config/      # Appwrite initialization & routing
│       │   ├── features/    # Domain-driven feature modules (Auth, Chat, Dashboard)
│       │   ├── services/    # External API integrations (AI, Appwrite, PDF)
│       │   ├── shared/      # Common UI components and utilities
│       │   └── theme/       # Design system, colors, and typography
├── backend-node/            # Node.js TypeScript API
│   └── src/
│       ├── controllers/     # Route handlers
│       ├── middleware/      # Authentication & validation layers
│       ├── routes/          # Express route definitions
│       └── services/        # Core business logic
├── .github/workflows/       # CI/CD pipelines for automated builds
└── setup_appwrite.ps1       # Automated database provisioning script
```

---

## 🤝 Contributing

We welcome contributions from the community! To ensure a smooth workflow, please follow these steps:

1. **Fork** the repository.
2. **Create a Feature Branch** (`git checkout -b feature/AmazingFeature`).
3. **Commit your Changes** (`git commit -m 'Add some AmazingFeature'`).
4. **Push to the Branch** (`git push origin feature/AmazingFeature`).
5. **Open a Pull Request** describing your changes in detail.

---

## 🛡️ License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for more information.

---

<div align="center">
  <p>Built with ❤️ by the MediConnect Team</p>
  <p><i>Transforming Healthcare through Technology</i></p>
</div>
