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
import { UserRole } from '../../../common/enums';

/**
 * USER entity per PRD Section 9.3.
 * Every user belongs to exactly one clinic tenant (SuperAdmin excepted).
 * Unique index on (tenant_id, email) ensures email uniqueness per tenant.
 */
@Entity('users')
@Index(['tenantId', 'email'], { unique: true })
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255 })
  email: string;

  @Column({ type: 'varchar', length: 255, name: 'password_hash' })
  passwordHash: string;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'first_name' })
  firstName: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'last_name' })
  lastName: string | null;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.PATIENT,
  })
  role: UserRole;

  @Column({ type: 'uuid', nullable: true, name: 'tenant_id' })
  tenantId: string | null; // null for SuperAdmin

  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive: boolean;

  @Column({ type: 'boolean', default: false, name: 'email_verified' })
  emailVerified: boolean;

  @Column({ type: 'int', default: 0, name: 'failed_login_attempts' })
  failedLoginAttempts: number;

  @Column({ type: 'timestamptz', nullable: true, name: 'locked_until' })
  lockedUntil: Date | null;

  @Column({ type: 'timestamptz', nullable: true, name: 'last_login_at' })
  lastLoginAt: Date | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;

  @OneToMany(() => Session, (session) => session.user)
  sessions: Session[];
}

/**
 * SESSION entity for refresh token management.
 * Supports rotating refresh tokens with reuse detection per PRD Section 12.2.
 */
@Entity('sessions')
export class Session {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId: string;

  @Column({ type: 'varchar', length: 512, name: 'refresh_token_hash' })
  refreshTokenHash: string;

  @Column({ type: 'varchar', length: 45, nullable: true, name: 'ip_address' })
  ipAddress: string | null;

  @Column({ type: 'text', nullable: true, name: 'user_agent' })
  userAgent: string | null;

  @Column({ type: 'timestamptz', name: 'expires_at' })
  expiresAt: Date;

  @Column({ type: 'boolean', default: false, name: 'is_revoked' })
  isRevoked: boolean;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User, (user) => user.sessions, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;
}

/**
 * PASSWORD_RESET_TOKEN entity.
 */
@Entity('password_reset_tokens')
export class PasswordResetToken {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId: string;

  @Column({ type: 'varchar', length: 512, name: 'token_hash' })
  tokenHash: string;

  @Column({ type: 'timestamptz', name: 'expires_at' })
  expiresAt: Date;

  @Column({ type: 'boolean', default: false, name: 'is_used' })
  isUsed: boolean;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;
}
