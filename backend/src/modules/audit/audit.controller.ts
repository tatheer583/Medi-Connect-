import {
  Controller,
  Get,
  Query,
  Param,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AuditService } from './audit.service';
import { Roles, CurrentUser } from '../../common/decorators';
import { RolesGuard } from '../../common/guards';
import { UserRole, AuditAction } from '../../common/enums';
import { AuthenticatedUser } from '../../common/interfaces';

/**
 * Audit controller per PRD Section 10.2.
 */
@ApiTags('Audit')
@Controller()
@UseGuards(AuthGuard('jwt'), RolesGuard)
@ApiBearerAuth('access-token')
export class AuditController {
  constructor(private readonly auditService: AuditService) {}

  @Get('clinics/:clinicId/audit-logs')
  @Roles(UserRole.CLINIC_ADMIN)
  @ApiOperation({ summary: 'Clinic Admin audit log search' })
  async getClinicAuditLogs(
    @Param('clinicId') clinicId: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('actorId') actorId?: string,
    @Query('patientId') patientId?: string,
    @Query('action') action?: AuditAction,
    @Query('resourceType') resourceType?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.auditService.getClinicAuditLogs(clinicId, page, limit, {
      actorId,
      patientId,
      action,
      resourceType,
      startDate,
      endDate,
    });
  }

  @Get('platform/audit-logs')
  @Roles(UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Super Admin audit log metadata (cross-tenant, no PHI)' })
  async getPlatformAuditLogs(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.auditService.getPlatformAuditLogs(page, limit);
  }
}
