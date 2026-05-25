// ============================================================
// Core TypeScript interfaces for MediConnectSmart
// ============================================================

// ─── User & Profiles ────────────────────────────────────────

export type UserType = 'doctor' | 'patient' | 'lab_technician' | 'admin';
export type Language = 'urdu' | 'english';
export type Gender = 'male' | 'female' | 'other';

export interface UserProfile {
  firstName: string;
  lastName: string;
  dateOfBirth: Date;
  gender: Gender;
  profileImage?: string;
  languagePreference: Language;
  timezone: string;
}

export interface ClinicInfo {
  id: string;
  name: string;
  address: string;
  city: string;
  phone: string;
}

export interface DoctorProfile extends UserProfile {
  medicalLicenseNumber: string;
  specialization: string;
  qualifications: string[];
  yearsOfExperience: number;
  clinic: ClinicInfo;
}

export interface EmergencyContact {
  name: string;
  relationship: string;
  phoneNumber: string;
}

export interface PatientProfile extends UserProfile {
  bloodGroup?: string;
  height?: number; // cm
  weight?: number; // kg
  emergencyContact: EmergencyContact;
}

export interface UserPreferences {
  notifications: boolean;
  language: Language;
  theme: 'light' | 'dark' | 'system';
}

export interface SecuritySettings {
  mfaEnabled: boolean;
  mfaMethod?: 'sms' | 'email';
  lastPasswordChange: Date;
}

export interface User {
  id: string;
  email: string;
  phoneNumber: string;
  userType: UserType;
  profile: UserProfile | DoctorProfile | PatientProfile;
  preferences: UserPreferences;
  security: SecuritySettings;
  createdAt: Date;
  updatedAt: Date;
  lastLoginAt: Date;
}

// ─── Doctor ─────────────────────────────────────────────────

export interface Doctor extends User {
  profile: DoctorProfile;
}

// ─── Patient ─────────────────────────────────────────────────

export interface Patient extends User {
  profile: PatientProfile;
}

// ─── Health Card ─────────────────────────────────────────────

export type MedicalHistoryStatus = 'active' | 'resolved' | 'chronic';

export interface MedicalHistory {
  id: string;
  condition: string;
  diagnosisDate: Date;
  treatment: string;
  status: MedicalHistoryStatus;
  notes?: string;
}

export interface CurrentMedication {
  id: string;
  name: string;
  dosage: string;
  frequency: string;
  startDate: Date;
  endDate?: Date;
  prescribedBy: string; // doctorId
  purpose?: string;
}

export interface Allergy {
  id: string;
  allergen: string;
  reaction: string;
  severity: 'mild' | 'moderate' | 'severe';
}

export interface ChronicCondition {
  id: string;
  condition: string;
  diagnosedDate: Date;
  managedBy?: string; // doctorId
}

export interface Vaccination {
  id: string;
  vaccine: string;
  date: Date;
  nextDueDate?: Date;
  administeredBy?: string;
}

export interface FamilyMedicalHistory {
  id: string;
  relation: string;
  condition: string;
  notes?: string;
}

export interface PersonalHealthInfo {
  bloodGroup?: string;
  height?: number;
  weight?: number;
  bmi?: number;
}

export interface HealthCard {
  id: string;
  patientId: string;
  personalInfo: PersonalHealthInfo;
  medicalHistory: MedicalHistory[];
  currentMedications: CurrentMedication[];
  allergies: Allergy[];
  chronicConditions: ChronicCondition[];
  vaccinations: Vaccination[];
  familyHistory: FamilyMedicalHistory[];
  createdAt: Date;
  updatedAt: Date;
  version: number;
}

// ─── Appointment ─────────────────────────────────────────────

export type AppointmentStatus =
  | 'scheduled'
  | 'confirmed'
  | 'cancelled'
  | 'completed'
  | 'no_show';

export type AppointmentType =
  | 'consultation'
  | 'follow_up'
  | 'emergency'
  | 'routine';

export type AppointmentPriority = 'low' | 'medium' | 'high' | 'emergency';

export interface ReminderSchedule {
  id: string;
  scheduledFor: Date;
  channel: 'push' | 'sms' | 'email';
  sent: boolean;
}

export interface Appointment {
  id: string;
  patientId: string;
  doctorId: string;
  clinicId: string;
  scheduledTime: Date;
  duration: number; // minutes
  status: AppointmentStatus;
  type: AppointmentType;
  reasonForVisit: string;
  symptoms?: string[];
  priority: AppointmentPriority;
  reminders: ReminderSchedule[];
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

// ─── Prescription ─────────────────────────────────────────────

export type PrescriptionStatus = 'active' | 'completed' | 'cancelled' | 'expired';

export interface MedicationDosage {
  amount: number;
  unit: string;
  form: string; // tablet, capsule, liquid, etc.
}

export interface MedicationFrequency {
  timesPerDay: number;
  timing: string[]; // ["morning", "evening"]
  withFood: boolean;
}

export interface MedicationDuration {
  days: number;
  startDate: Date;
  endDate: Date;
}

export interface MedicationInteraction {
  drug: string;
  severity: 'mild' | 'moderate' | 'severe';
  description: string;
}

export interface PrescribedMedication {
  id: string;
  medicationName: string;
  genericName?: string;
  dosage: MedicationDosage;
  frequency: MedicationFrequency;
  duration: MedicationDuration;
  route: 'oral' | 'topical' | 'inhalation' | 'injection';
  purpose?: string;
  sideEffects?: string[];
  interactions?: MedicationInteraction[];
}

export interface RefillInfo {
  allowed: boolean;
  count: number;
  remaining: number;
  lastRefillDate?: Date;
}

export interface DigitalSignature {
  signedBy: string;
  signedAt: Date;
  certificate?: string;
}

export interface Prescription {
  id: string;
  patientId: string;
  doctorId: string;
  clinicalRecordId: string;
  issueDate: Date;
  validUntil: Date;
  medications: PrescribedMedication[];
  instructions: string;
  precautions: string[];
  refills: RefillInfo;
  status: PrescriptionStatus;
  pharmacyNotes?: string;
  signature: DigitalSignature;
  qrCode: string;
  createdAt: Date;
  updatedAt: Date;
  dispensedAt?: Date;
  lastRefillAt?: Date;
}

// ─── Chat Message ─────────────────────────────────────────────

export type MessageType = 'text' | 'image' | 'document' | 'audio';
export type MessageStatus = 'sent' | 'delivered' | 'read' | 'failed';

export interface Attachment {
  id: string;
  name: string;
  url: string;
  mimeType: string;
  size: number;
}

export interface MessageMetadata {
  encryptionKey: string;
  iv: string;
  algorithm: string;
  signature: string;
  contentType: string;
  fileSize?: number;
  mimeType?: string;
}

export interface ChatMessage {
  id: string;
  conversationId: string;
  senderId: string;
  recipientId: string;
  messageType: MessageType;
  content: string;
  encryptedContent: string;
  metadata: MessageMetadata;
  attachments?: Attachment[];
  status: MessageStatus;
  timestamp: Date;
  appointmentId?: string;
  isUrgent: boolean;
  requiresResponse: boolean;
}

// ─── Auth ─────────────────────────────────────────────────────

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  user: User;
  expiresIn: number;
}

export interface RegistrationData {
  email: string;
  password: string;
  phoneNumber: string;
  userType: UserType;
  profile: Partial<UserProfile>;
}

// ─── API ──────────────────────────────────────────────────────

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  hasMore: boolean;
}
