import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { ClinicStatus } from '../../../common/enums';
import { Branch } from './branch.entity';

/**
 * CLINIC entity — the tenant root per PRD Section 9.3.
 * This is the only tenant-scoped table without a tenant_id column;
 * it IS the tenant.
 */
@Entity('clinics')
export class Clinic {
  @PrimaryGeneratedColumn('uuid', { name: 'clinic_id' })
  clinicId: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ type: 'varchar', length: 500, nullable: true, name: 'logo_url' })
  logoUrl: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  email: string | null;

  @Column({ type: 'varchar', length: 50, nullable: true })
  phone: string | null;

  @Column({ type: 'varchar', length: 500, nullable: true })
  website: string | null;

  @Column({
    type: 'enum',
    enum: ClinicStatus,
    default: ClinicStatus.PENDING,
  })
  status: ClinicStatus;

  @Column({ type: 'varchar', length: 100, default: 'UTC' })
  timezone: string;

  @Column({ type: 'varchar', length: 10, default: 'en' })
  locale: string;

  @Column({ type: 'varchar', length: 10, default: 'USD' })
  currency: string;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;

  @OneToMany(() => Branch, (branch) => branch.clinic)
  branches: Branch[];
}
