import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';
import { AuditAction } from '../../../common/enums';

/**
 * AUDIT_LOG_ENTRY entity per PRD Section 6.19 and 9.3.
 * Append-only, no UPDATE or DELETE grants at the DB role level.
 * Every PHI read/write is logged with actor, tenant, patient, action, timestamp.
 */
@Entity('audit_log_entries')
@Index(['tenantId', 'timestamp'])
@Index(['actorId', 'timestamp'])
@Index(['patientId', 'timestamp'])
export class AuditLogEntry {
  @PrimaryGeneratedColumn('uuid', { name: 'log_id' })
  logId: string;

  @Column({ type: 'uuid', name: 'tenant_id' })
  tenantId: string;

  @Column({ type: 'uuid', name: 'actor_id' })
  actorId: string;

  @Column({ type: 'uuid', nullable: true, name: 'patient_id' })
  patientId: string | null;

  @Column({
    type: 'enum',
    enum: AuditAction,
  })
  action: AuditAction;

  @Column({ type: 'varchar', length: 100, name: 'resource_type' })
  resourceType: string;

  @Column({ type: 'uuid', nullable: true, name: 'resource_id' })
  resourceId: string | null;

  @Column({ type: 'jsonb', nullable: true })
  details: Record<string, unknown> | null;

  @Column({ type: 'varchar', length: 45, nullable: true, name: 'ip_address' })
  ipAddress: string | null;

  @Column({ type: 'text', nullable: true, name: 'user_agent' })
  userAgent: string | null;

  @Column({ type: 'timestamptz', default: () => 'CURRENT_TIMESTAMP' })
  timestamp: Date;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  // No UpdateDateColumn — audit logs are APPEND ONLY per PRD Section 6.19
}
