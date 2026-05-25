// ─── User & Profile Types ─────────────────────────────────────────────────────

export type UserType = 'doctor' | 'patient' | 'lab_technician' | 'admin';
export type Language = 'urdu' | 'english';
export type Gender = 'male' | 'female' | 'other';

export interface ClinicInfo {
  id?: string;
  name: string;
  address: string;
  city: string;
  phone: string;
}

export interface EmergencyContact {
  name: string;
  relationship: string;
  phoneNumber: string;
}

export interface UserProfile {
  firstName: string;
  lastName: string;
  dateOfBirth?: string; // ISO date string
  gender?: Gender;
  profileImage?: string;
  languagePreference: Language;
  timezone: string;
}

export interface DoctorProfile extends UserProfile {
  medicalLicenseNumber: string; // PMDC license
  specialization: string;
  qualifications?: string[];
  yearsOfExperience?: number;
  clinic?: ClinicInfo;
  consultationFee?: number;
  bio?: string;
  languages?: string[];
}

export interface PatientProfile extends UserProfile {
  cnic?: string;
  bloodGroup?: string;
  height?: number; // cm
  weight?: number; // kg
  emergencyContact?: EmergencyContact;
}

export interface UserPreferences {
  notifications: boolean;
  language: Language;
  theme: 'light' | 'dark' | 'system';
}

export interface SecuritySettings {
  mfaEnabled: boolean;
  mfaMethod?: 'sms' | 'email';
  lastPasswordChange?: string;
}

// ─── Core User Entity ─────────────────────────────────────────────────────────

export interface User {
  id: string;
  email: string;
  phoneNumber: string;
  userType: UserType;
  profile: UserProfile | DoctorProfile | PatientProfile;
  preferences: UserPreferences;
  security: SecuritySettings;
  isVerified: boolean;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  lastLoginAt?: string;
}

export interface Doctor extends User {
  userType: 'doctor';
  profile: DoctorProfile;
}

export interface Patient extends User {
  userType: 'patient';
  profile: PatientProfile;
}

// ─── Registration DTOs ────────────────────────────────────────────────────────

export interface RegisterDoctorDto {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phone: string;
  pmdcLicense: string;
  specialization: string;
  clinicName?: string;
  clinicAddress?: string;
}

export interface RegisterPatientDto {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phone: string;
  dateOfBirth: string;
  bloodGroup?: string;
  emergencyContactName?: string;
  emergencyContactPhone?: string;
}
