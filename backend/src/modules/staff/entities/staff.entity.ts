import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { UserRole, StaffStatus } from '../../../common/enums';

/**
 * STAFF_MEMBER entity per PRD Section 9.3.
 * Manages clinic employees — Doctors, Nurses, Receptionists, Agents.
 */
@Entity('staff_members')
@Index(['clinicId', 'staffId'])
export class StaffMember {
  @PrimaryGeneratedColumn('uuid', { name: 'staff_id' })
  staffId: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId: string;

  @Column({ type: 'uuid', name: 'clinic_id' })
  clinicId: string;

  @Column({ type: 'uuid', nullable: true, name: 'department_id' })
  departmentId: string | null;

  @Column({
    type: 'enum',
    enum: UserRole,
    name: 'role_enum',
  })
  roleEnum: UserRole;

  @Column({
    type: 'enum',
    enum: StaffStatus,
    default: StaffStatus.INVITED,
  })
  status: StaffStatus;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;
}

/**
 * STAFF_INVITE entity for email-based staff invitations.
 */
@Entity('staff_invites')
export class StaffInvite {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', name: 'clinic_id' })
  clinicId: string;

  @Column({ type: 'varchar', length: 255 })
  email: string;

  @Column({
    type: 'enum',
    enum: UserRole,
  })
  role: UserRole;

  @Column({ type: 'uuid', nullable: true, name: 'department_id' })
  departmentId: string | null;

  @Column({ type: 'varchar', length: 512, name: 'invite_token_hash' })
  inviteTokenHash: string;

  @Column({ type: 'timestamptz', name: 'expires_at' })
  expiresAt: Date;

  @Column({ type: 'boolean', default: false, name: 'is_accepted' })
  isAccepted: boolean;

  @Column({ type: 'uuid', name: 'invited_by' })
  invitedBy: string;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;
}
