/**
 * User roles as defined in PRD Section 4.
 * Every human account belongs to exactly one clinic tenant (SuperAdmin excepted).
 */
export enum UserRole {
  SUPER_ADMIN = 'super_admin',
  CLINIC_ADMIN = 'clinic_admin',
  DOCTOR = 'doctor',
  NURSE = 'nurse',
  RECEPTIONIST = 'receptionist',
  AGENT = 'agent',
  PATIENT = 'patient',
}

/**
 * Appointment statuses following the lifecycle:
 * requested → confirmed → checked_in → in_progress → completed/cancelled/no_show
 */
export enum AppointmentStatus {
  REQUESTED = 'requested',
  CONFIRMED = 'confirmed',
  CHECKED_IN = 'checked_in',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  NO_SHOW = 'no_show',
}

/**
 * Appointment type (in-person, video, voice)
 */
export enum AppointmentType {
  IN_PERSON = 'in_person',
  VIDEO = 'video',
  VOICE = 'voice',
}

/**
 * Medical record entry types per PRD Section 6.7
 */
export enum RecordEntryType {
  DIAGNOSIS = 'diagnosis',
  HISTORY = 'history',
  SYMPTOM = 'symptom',
  NOTE = 'note',
  FOLLOW_UP = 'follow_up',
}

/**
 * Prescription status
 */
export enum PrescriptionStatus {
  DRAFT = 'draft',
  FINALIZED = 'finalized',
  CANCELLED = 'cancelled',
}

/**
 * Clinic status
 */
export enum ClinicStatus {
  PENDING = 'pending',
  ACTIVE = 'active',
  SUSPENDED = 'suspended',
  ARCHIVED = 'archived',
}

/**
 * Staff member status
 */
export enum StaffStatus {
  INVITED = 'invited',
  ACTIVE = 'active',
  DEACTIVATED = 'deactivated',
}

/**
 * Audit log action types
 */
export enum AuditAction {
  CREATE = 'create',
  READ = 'read',
  UPDATE = 'update',
  DELETE = 'delete',
  LOGIN = 'login',
  LOGIN_FAILED = 'login_failed',
  LOGOUT = 'logout',
  ACCESS_GRANT_CREATED = 'access_grant_created',
  ACCESS_GRANT_EXPIRED = 'access_grant_expired',
  PRESCRIPTION_FINALIZED = 'prescription_finalized',
  RECORD_ENTRY_CREATED = 'record_entry_created',
}
