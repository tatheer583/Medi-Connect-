import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Branch } from './branch.entity';

/**
 * DEPARTMENT entity per PRD Section 9.3.
 */
@Entity('departments')
export class Department {
  @PrimaryGeneratedColumn('uuid', { name: 'department_id' })
  departmentId: string;

  @Column({ type: 'uuid', name: 'branch_id' })
  branchId: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive: boolean;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => Branch, (branch) => branch.departments, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'branch_id' })
  branch: Branch;
}
