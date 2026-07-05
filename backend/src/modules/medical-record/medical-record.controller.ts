import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { MedicalRecordService } from './medical-record.service';
import { Roles, CurrentUser } from '../../common/decorators';
import { RolesGuard } from '../../common/guards';
import { UserRole, RecordEntryType } from '../../common/enums';
import type { AuthenticatedUser } from '../../common/interfaces';

/**
 * Medical Records controller per PRD Section 10.2.
 */
@ApiTags('Medical Records')
@Controller('patients/:patientId/records')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@ApiBearerAuth('access-token')
export class MedicalRecordController {
  constructor(private readonly recordService: MedicalRecordService) {}

  @Post()
  @Roles(UserRole.DOCTOR)
  @ApiOperation({ summary: 'Create a record entry (new version if amending)' })
  async createEntry(
    @Param('patientId') patientId: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: {
      type: RecordEntryType;
      content: string;
      appointmentId?: string;
      structuredData?: Record<string, unknown>;
      previousVersionId?: string;
    },
  ) {
    return this.recordService.createEntry({
      patientId,
      doctorId: user.userId,
      clinicId: user.tenantId!,
      ...body,
    });
  }

  @Get()
  @Roles(UserRole.DOCTOR, UserRole.NURSE, UserRole.PATIENT)
  @ApiOperation({ summary: 'List record entries, filterable by type' })
  async listEntries(
    @Param('patientId') patientId: string,
    @Query('type') type?: RecordEntryType,
  ) {
    return this.recordService.listEntries(patientId, type);
  }

  @Get(':recordId')
  @Roles(UserRole.DOCTOR, UserRole.NURSE, UserRole.PATIENT)
  @ApiOperation({ summary: 'Get a specific record entry' })
  async getEntry(@Param('recordId') recordId: string) {
    return this.recordService.getEntry(recordId);
  }

  @Get(':recordId/history')
  @Roles(UserRole.DOCTOR, UserRole.CLINIC_ADMIN)
  @ApiOperation({ summary: 'Get version history for a record entry' })
  async getVersionHistory(@Param('recordId') recordId: string) {
    return this.recordService.getVersionHistory(recordId);
  }

  @Post(':recordId/sign')
  @Roles(UserRole.DOCTOR)
  @ApiOperation({ summary: 'Sign/finalize a record entry' })
  async signEntry(
    @Param('recordId') recordId: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.recordService.signEntry(recordId, user.userId);
  }
}
