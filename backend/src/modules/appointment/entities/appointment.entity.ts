import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import { AppointmentStatus, AppointmentType } from '../../../common/enums';

/**
 * APPOINTMENT entity per PRD Section 9.3.
 * Lifecycle: requested → confirmed → checked_in → in_progress → completed/cancelled/no_show
 * Exclusion constraint on (doctor_id, time range) prevents double-booking at the DB level.
 */
@Entity('appointments')
@Index(['doctorId', 'scheduledAt'])
@Index(['patientId', 'scheduledAt'])
@Index(['clinicId', 'branchId', 'scheduledAt'])
export class Appointment {
  @PrimaryGeneratedColumn('uuid', { name: 'appointment_id' })
  appointmentId: string;

  @Column({ type: 'uuid', name: 'patient_id' })
  patientId: string;

  @Column({ type: 'uuid', name: 'doctor_id' })
  doctorId: string;

  @Column({ type: 'uuid', name: 'branch_id' })
  branchId: string;

  @Column({ type: 'uuid', name: 'clinic_id' })
  clinicId: string;

  @Column({ type: 'timestamptz', name: 'scheduled_at' })
  scheduledAt: Date;

  @Column({ type: 'timestamptz', name: 'ends_at' })
  endsAt: Date;

  @Column({
    type: 'enum',
    enum: AppointmentStatus,
    default: AppointmentStatus.REQUESTED,
  })
  status: AppointmentStatus;

  @Column({
    type: 'enum',
    enum: AppointmentType,
    default: AppointmentType.IN_PERSON,
  })
  type: AppointmentType;

  @Column({ type: 'text', nullable: true, name: 'visit_reason' })
  visitReason: string | null;

  @Column({ type: 'text', nullable: true })
  notes: string | null;

  @Column({ type: 'timestamptz', nullable: true, name: 'checked_in_at' })
  checkedInAt: Date | null;

  @Column({ type: 'timestamptz', nullable: true, name: 'cancelled_at' })
  cancelledAt: Date | null;

  @Column({ type: 'text', nullable: true, name: 'cancellation_reason' })
  cancellationReason: string | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;
}
