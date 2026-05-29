<h1 align="center">🏥 MediConnect Smart</h1>

<p align="center">
  <strong>AI-Powered Healthcare Management Platform</strong>
</p>

<p align="center">
  <a href="https://github.com/tatheer583/Medi-Connect-/releases/download/v1.0.0/mediconnect-v1.0.0.apk">
    <img src="https://img.shields.io/badge/Download-v1.0.0_APK-blue?style=for-the-badge&logo=android" alt="Download APK" />
  </a>
  <br />
  <img src="https://img.shields.io/badge/Flutter-3.11+-02569B?logo=flutter&logoColor=white" alt="Flutter Version" />
  <img src="https://img.shields.io/badge/Node.js-16+-339933?logo=nodedotjs&logoColor=white" alt="Node.js Version" />
  <img src="https://img.shields.io/badge/Appwrite-Cloud-F02E65?logo=appwrite&logoColor=white" alt="Appwrite Cloud" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License" />
</p>

---

## 📖 Table of Contents
- [About the Project](#-about-the-project)
- [Core Features](#-core-features)
- [System Architecture](#-system-architecture)
- [Tech Stack](#-tech-stack)
- [Installation & Setup](#-installation--setup)
- [Environment Variables](#-environment-variables)
- [Screenshots](#-screenshots)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🚀 About the Project

**MediConnect Smart** is a comprehensive, AI-powered healthcare application designed to bridge the gap between healthcare providers, clinics, and patients. By providing a unified mobile platform, MediConnect streamlines appointment scheduling, enables secure doctor-patient communication, and leverages the power of OpenAI to generate intelligent clinical summaries and automate routine healthcare management tasks.

### Why MediConnect?
- **Efficiency**: Automates routine tasks for clinics and doctors.
- **Accessibility**: Gives patients easy access to their health records, prescriptions, and doctors.
- **Intelligence**: Utilizes cutting-edge AI to provide clinical insights and automated summaries.

---

## ✨ Core Features

### 👨‍⚕️ For Doctors
- **Appointment Management**: Seamlessly view, accept, or reschedule patient appointments.
- **Digital Prescriptions**: Generate and share digital prescriptions securely.
- **Patient Communication**: Real-time encrypted chat with patients.
- **AI Patient Summaries**: Instant, AI-generated summaries of patient histories and consultations.

### 👤 For Patients
- **Book Appointments**: Find and book appointments with available doctors.
- **Medicine Reminders**: Automated alerts for timely medication.
- **Secure Chat**: Direct communication with healthcare providers.
- **Health Records**: Track lab results, prescriptions, and historical medical data.

### 🏥 For Clinics
- **Clinic Dashboard**: Comprehensive overview of clinic operations.
- **Staff Management**: Add and manage clinic staff, doctors, and receptionists.
- **Analytics**: Gain insights into appointment trends, patient inflow, and overall clinic performance.

---

## 🏗️ System Architecture

MediConnect operates on a robust dual-layer architecture:
1. **Frontend (Mobile App)**: Built with Flutter and Riverpod for state management, providing a smooth, cross-platform experience.
2. **Backend Services**: Powered by Node.js and Express, integrated closely with Appwrite Cloud for authentication and database management, and OpenAI for intelligent data processing.

---

## 🛠️ Tech Stack

| Component | Technology | Description |
|-----------|------------|-------------|
| **Mobile App** | Flutter & Dart | Cross-platform UI development |
| **State Management**| Riverpod | Reactive caching and data binding |
| **Backend API** | Node.js, Express, TS | RESTful APIs and business logic |
| **BaaS** | Appwrite Cloud | Authentication, Database, Storage |
| **Artificial Intelligence**| OpenAI (GPT-4o-mini) | AI summaries and automated insights |

---

## 💻 Installation & Setup

### Prerequisites
Make sure you have the following installed on your local machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.11 or higher)
- [Node.js](https://nodejs.org/) (v16 or higher)
- An active [Appwrite Cloud](https://appwrite.io/) account
- An active [OpenAI](https://openai.com/) API key

### 1. Clone the Repository
```bash
git clone https://github.com/tatheer583/Medi-Connect-.git
cd Medi-Connect-
```

### 2. Backend Setup
Navigate to the backend directory, install dependencies, and start the server:
```bash
cd backend-node
npm install
npm run dev
```

### 3. Mobile App Setup
Open a new terminal, navigate to the mobile directory, install dependencies, and launch the app:
```bash
cd mobile
flutter pub get
flutter run
```

---

## 🔐 Environment Variables

To run this project, you will need to add the following environment variables.

### Backend (`backend-node/.env`)
Create a `.env` file in the `backend-node` directory based on the `.env.example`:
```env
APPWRITE_ENDPOINT="https://cloud.appwrite.io/v1"
APPWRITE_PROJECT_ID="your_project_id"
APPWRITE_API_KEY="your_api_key"
OPENAI_API_KEY="your_openai_api_key"
PORT=3000
```

---

## 📸 Screenshots

*(Replace these with actual screenshots of your application)*

<p align="center">
  <img src="https://via.placeholder.com/250x500.png?text=Login+Screen" alt="Login Screen" width="200" style="margin-right: 10px;"/>
  <img src="https://via.placeholder.com/250x500.png?text=Home+Dashboard" alt="Home Dashboard" width="200" style="margin-right: 10px;"/>
  <img src="https://via.placeholder.com/250x500.png?text=Doctor+Chat" alt="Doctor Chat" width="200" />
</p>

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 📞 Support

For support, please open an issue on the [GitHub Issues](https://github.com/tatheer583/Medi-Connect-/issues) page.

<p align="center">
  Built with ❤️ by the MediConnect Team
</p>
