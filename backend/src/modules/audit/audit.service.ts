import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AuditLogEntry } from './entities';
import { AuditAction } from '../../common/enums';

/**
 * Audit service per PRD Section 6.19.
 * An immutable record of who accessed or changed what, when, and from where.
 * Append-only storage — no update or delete API, not even for SuperAdmin.
 */
@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);

  constructor(
    @InjectRepository(AuditLogEntry)
    private readonly auditRepository: Repository<AuditLogEntry>,
  ) {}

  /**
   * Log an audit event. This is the primary method called by other modules
   * and the audit interceptor.
   */
  async log(data: {
    tenantId: string;
    actorId: string;
    patientId?: string;
    action: AuditAction;
    resourceType: string;
    resourceId?: string;
    details?: Record<string, unknown>;
    ipAddress?: string;
    userAgent?: string;
  }): Promise<AuditLogEntry> {
    const entry = this.auditRepository.create({
      tenantId: data.tenantId,
      actorId: data.actorId,
      patientId: data.patientId || null,
      action: data.action,
      resourceType: data.resourceType,
      resourceId: data.resourceId || null,
      details: data.details || null,
      ipAddress: data.ipAddress || null,
      userAgent: data.userAgent || null,
      timestamp: new Date(),
    });

    return this.auditRepository.save(entry);
  }

  /**
   * Search clinic audit logs (Clinic Admin — own tenant only).
   */
  async getClinicAuditLogs(
    tenantId: string,
    page: number = 1,
    limit: number = 50,
    filters?: {
      actorId?: string;
      patientId?: string;
      action?: AuditAction;
      resourceType?: string;
      startDate?: string;
      endDate?: string;
    },
  ) {
    const query = this.auditRepository
      .createQueryBuilder('audit')
      .where('audit.tenant_id = :tenantId', { tenantId })
      .orderBy('audit.timestamp', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    if (filters?.actorId) {
      query.andWhere('audit.actor_id = :actorId', { actorId: filters.actorId });
    }
    if (filters?.patientId) {
      query.andWhere('audit.patient_id = :patientId', { patientId: filters.patientId });
    }
    if (filters?.action) {
      query.andWhere('audit.action = :action', { action: filters.action });
    }
    if (filters?.resourceType) {
      query.andWhere('audit.resource_type = :resourceType', { resourceType: filters.resourceType });
    }
    if (filters?.startDate) {
      query.andWhere('audit.timestamp >= :startDate', { startDate: filters.startDate });
    }
    if (filters?.endDate) {
      query.andWhere('audit.timestamp <= :endDate', { endDate: filters.endDate });
    }

    const [data, total] = await query.getManyAndCount();

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  /**
   * Platform audit logs for Super Admin — metadata only, no underlying PHI.
   * Per PRD Section 6.19: SuperAdmin sees log metadata across tenants,
   * not the underlying PHI itself.
   */
  async getPlatformAuditLogs(page: number = 1, limit: number = 50) {
    const [data, total] = await this.auditRepository.findAndCount({
      select: { logId: true, tenantId: true, actorId: true, action: true, resourceType: true, timestamp: true },
      skip: (page - 1) * limit,
      take: limit,
      order: { timestamp: 'DESC' },
    });

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }
}
