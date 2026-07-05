import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { PrescriptionStatus } from '../../../common/enums';

/**
 * PRESCRIPTION entity per PRD Section 6.8 and 9.3.
 * Only the Doctor role can create or finalize a prescription.
 */
@Entity('prescriptions')
@Index(['clinicId', 'patientId'])
export class Prescription {
  @PrimaryGeneratedColumn('uuid', { name: 'prescription_id' })
  prescriptionId: string;

  @Column({ type: 'uuid', name: 'patient_id' })
  patientId: string;

  @Column({ type: 'uuid', name: 'doctor_id' })
  doctorId: string;

  @Column({ type: 'uuid', name: 'clinic_id' })
  clinicId: string;

  @Column({ type: 'uuid', nullable: true, name: 'record_id' })
  recordId: string | null;

  @Column({
    type: 'enum',
    enum: PrescriptionStatus,
    default: PrescriptionStatus.DRAFT,
  })
  status: PrescriptionStatus;

  @Column({ type: 'text', nullable: true })
  notes: string | null;

  @Column({ type: 'timestamptz', nullable: true, name: 'issued_at' })
  issuedAt: Date | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;

  @OneToMany(() => PrescriptionItem, (item) => item.prescription, { cascade: true })
  items: PrescriptionItem[];
}

/**
 * PRESCRIPTION_ITEM entity per PRD Section 9.3.
 * Drug, dose, frequency, duration, instructions.
 */
@Entity('prescription_items')
export class PrescriptionItem {
  @PrimaryGeneratedColumn('uuid', { name: 'item_id' })
  itemId: string;

  @Column({ type: 'uuid', name: 'prescription_id' })
  prescriptionId: string;

  @Column({ type: 'varchar', length: 255 })
  drug: string;

  @Column({ type: 'varchar', length: 100 })
  dose: string;

  @Column({ type: 'varchar', length: 100 })
  frequency: string;

  @Column({ type: 'varchar', length: 100 })
  duration: string;

  @Column({ type: 'text', nullable: true })
  instructions: string | null;

  @Column({ type: 'boolean', default: false, name: 'is_controlled_substance' })
  isControlledSubstance: boolean;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => Prescription, (p) => p.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'prescription_id' })
  prescription: Prescription;
}
