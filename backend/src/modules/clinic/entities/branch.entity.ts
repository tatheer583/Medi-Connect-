import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from 'typeorm';
import { Clinic } from './clinic.entity';
import { Department } from './department.entity';

/**
 * BRANCH entity per PRD Section 9.3.
 * Multi-branch support with per-branch timezone and address.
 * Composite index on (clinic_id, branch_id) for RLS-backed queries.
 */
@Entity('branches')
@Index(['clinicId', 'branchId'])
export class Branch {
  @PrimaryGeneratedColumn('uuid', { name: 'branch_id' })
  branchId: string;

  @Column({ type: 'uuid', name: 'clinic_id' })
  clinicId: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'text', nullable: true })
  address: string | null;

  @Column({ type: 'varchar', length: 100, nullable: true })
  city: string | null;

  @Column({ type: 'varchar', length: 100, nullable: true })
  state: string | null;

  @Column({ type: 'varchar', length: 20, nullable: true, name: 'postal_code' })
  postalCode: string | null;

  @Column({ type: 'varchar', length: 100, nullable: true })
  country: string | null;

  @Column({ type: 'varchar', length: 50, nullable: true })
  phone: string | null;

  @Column({ type: 'varchar', length: 100, default: 'UTC' })
  timezone: string;

  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive: boolean;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => Clinic, (clinic) => clinic.branches, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'clinic_id' })
  clinic: Clinic;

  @OneToMany(() => Department, (dept) => dept.branch)
  departments: Department[];
}
