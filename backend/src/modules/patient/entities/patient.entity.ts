import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

/**
 * PATIENT_PROFILE entity per PRD Section 9.3.
 * Composite index on (clinic_id, patient_id) for RLS-backed queries.
 * A patient record belongs to exactly one clinic tenant by default.
 */
@Entity('patient_profiles')
@Index(['clinicId', 'patientId'])
export class PatientProfile {
  @PrimaryGeneratedColumn('uuid', { name: 'patient_id' })
  patientId: string;

  @Column({ type: 'uuid', name: 'clinic_id' })
  clinicId: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId: string;

  @Column({ type: 'varchar', length: 255, name: 'first_name' })
  firstName: string;

  @Column({ type: 'varchar', length: 255, name: 'last_name' })
  lastName: string;

  @Column({ type: 'date', name: 'date_of_birth' })
  dateOfBirth: Date;

  @Column({ type: 'varchar', length: 10, nullable: true })
  gender: string | null;

  @Column({ type: 'varchar', length: 50, nullable: true })
  phone: string | null;

  @Column({ type: 'text', nullable: true })
  address: string | null;

  @Column({ type: 'varchar', length: 20, nullable: true, name: 'blood_type' })
  bloodType: string | null;

  @Column({ type: 'varchar', length: 500, nullable: true, name: 'photo_url' })
  photoUrl: string | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;
}

/**
 * EMERGENCY_CONTACT entity per PRD Section 6.5.
 */
@Entity('emergency_contacts')
export class EmergencyContact {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', name: 'patient_id' })
  patientId: string;

  @Column({ type: 'uuid', name: 'clinic_id' })
  clinicId: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'varchar', length: 100 })
  relationship: string;

  @Column({ type: 'varchar', length: 50 })
  phone: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  email: string | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;
}

/**
 * INSURANCE_INFO entity per PRD Section 6.5.
 * Data capture only; claims processing is out of scope for v1.
 */
@Entity('insurance_info')
export class InsuranceInfo {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', name: 'patient_id' })
  patientId: string;

  @Column({ type: 'uuid', name: 'clinic_id' })
  clinicId: string;

  @Column({ type: 'varchar', length: 255, name: 'provider_name' })
  providerName: string;

  @Column({ type: 'varchar', length: 100, name: 'policy_number' })
  policyNumber: string;

  @Column({ type: 'varchar', length: 100, nullable: true, name: 'group_number' })
  groupNumber: string | null;

  @Column({ type: 'date', nullable: true, name: 'valid_until' })
  validUntil: Date | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;
}
