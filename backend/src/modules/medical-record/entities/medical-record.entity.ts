import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';
import { RecordEntryType } from '../../../common/enums';

/**
 * MEDICAL_RECORD_ENTRY entity per PRD Section 6.7 and 9.3.
 * Append-only, versioned entries — never hard-deleted or silently overwritten.
 * Corrections create a new version so the full history survives.
 */
@Entity('medical_record_entries')
@Index(['patientId', 'createdAt'])
@Index(['clinicId', 'patientId'])
export class MedicalRecordEntry {
  @PrimaryGeneratedColumn('uuid', { name: 'record_id' })
  recordId: string;

  @Column({ type: 'uuid', name: 'patient_id' })
  patientId: string;

  @Column({ type: 'uuid', name: 'doctor_id' })
  doctorId: string;

  @Column({ type: 'uuid', name: 'clinic_id' })
  clinicId: string;

  @Column({ type: 'uuid', nullable: true, name: 'appointment_id' })
  appointmentId: string | null;

  @Column({
    type: 'enum',
    enum: RecordEntryType,
  })
  type: RecordEntryType;

  @Column({ type: 'text' })
  content: string;

  @Column({ type: 'jsonb', nullable: true, name: 'structured_data' })
  structuredData: Record<string, unknown> | null;

  @Column({ type: 'int', default: 1 })
  version: number;

  @Column({ type: 'uuid', nullable: true, name: 'previous_version_id' })
  previousVersionId: string | null;

  @Column({ type: 'boolean', default: false, name: 'is_signed' })
  isSigned: boolean;

  @Column({ type: 'timestamptz', nullable: true, name: 'signed_at' })
  signedAt: Date | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  // No UpdateDateColumn — records are append-only per PRD Section 6.7
}
