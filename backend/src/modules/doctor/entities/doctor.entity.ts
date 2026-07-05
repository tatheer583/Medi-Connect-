import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

/**
 * DOCTOR_PROFILE entity per PRD Section 9.3.
 * Specialty, license number, e-signature.
 */
@Entity('doctor_profiles')
@Index(['licenseNumber'], { unique: true })
export class DoctorProfile {
  @PrimaryGeneratedColumn('uuid', { name: 'doctor_id' })
  doctorId: string;

  @Column({ type: 'uuid', name: 'staff_id' })
  staffId: string;

  @Column({ type: 'uuid', name: 'clinic_id' })
  clinicId: string;

  @Column({ type: 'varchar', length: 255 })
  specialty: string;

  @Column({ type: 'varchar', length: 100, name: 'license_number' })
  licenseNumber: string;

  @Column({ type: 'text', nullable: true })
  bio: string | null;

  @Column({ type: 'int', default: 30, name: 'consultation_duration_minutes' })
  consultationDurationMinutes: number;

  @Column({ type: 'text', nullable: true, name: 'e_signature_url' })
  eSignatureUrl: string | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;
}

/**
 * PATIENT_DOCTOR_ASSIGNMENT per PRD Section 9.3.
 * Core mechanism for scoping doctor access to assigned patients only.
 */
@Entity('patient_doctor_assignments')
@Index(['patientId', 'doctorId'], { unique: true })
export class PatientDoctorAssignment {
  @PrimaryGeneratedColumn('uuid', { name: 'assignment_id' })
  assignmentId: string;

  @Column({ type: 'uuid', name: 'patient_id' })
  patientId: string;

  @Column({ type: 'uuid', name: 'doctor_id' })
  doctorId: string;

  @Column({ type: 'uuid', name: 'clinic_id' })
  clinicId: string;

  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive: boolean;

  @Column({ type: 'timestamptz', name: 'assigned_at' })
  assignedAt: Date;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;
}

/**
 * ACCESS_GRANT per PRD Section 6.5.
 * Time-boxed, audited cross-doctor access to a patient's records.
 * "Doctor A never sees Doctor B's patients unless explicitly authorized."
 */
@Entity('access_grants')
@Index(['expiresAt'])
export class AccessGrant {
  @PrimaryGeneratedColumn('uuid', { name: 'grant_id' })
  grantId: string;

  @Column({ type: 'uuid', name: 'patient_id' })
  patientId: string;

  @Column({ type: 'uuid', name: 'grantor_id' })
  grantorId: string; // Doctor or ClinicAdmin who granted access

  @Column({ type: 'uuid', name: 'grantee_id' })
  granteeId: string; // Doctor receiving access

  @Column({ type: 'uuid', name: 'clinic_id' })
  clinicId: string;

  @Column({ type: 'varchar', length: 100, default: 'read' })
  scope: string; // 'read', 'read_write'

  @Column({ type: 'text' })
  reason: string;

  @Column({ type: 'timestamptz', name: 'expires_at' })
  expiresAt: Date;

  @Column({ type: 'boolean', default: false, name: 'is_revoked' })
  isRevoked: boolean;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;
}
