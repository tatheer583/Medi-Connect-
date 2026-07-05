import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { DoctorService } from './doctor.service';
import { Roles, CurrentUser } from '../../common/decorators';
import { RolesGuard } from '../../common/guards';
import { UserRole } from '../../common/enums';
import type { AuthenticatedUser } from '../../common/interfaces';

@ApiTags('Doctors')
@Controller('doctors')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@ApiBearerAuth('access-token')
export class DoctorController {
  constructor(private readonly doctorService: DoctorService) {}

  @Get(':id/patients')
  @Roles(UserRole.DOCTOR, UserRole.CLINIC_ADMIN)
  @ApiOperation({ summary: 'Get assigned patients' })
  async getAssignedPatients(
    @Param('id') doctorId: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.doctorService.getAssignedPatients(doctorId, user.tenantId!);
  }

  @Post('access-grants')
  @Roles(UserRole.DOCTOR, UserRole.CLINIC_ADMIN)
  @ApiOperation({ summary: 'Create an access grant for a specialist' })
  async createAccessGrant(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: {
      patientId: string;
      granteeId: string;
      reason: string;
      expiresInDays?: number;
    },
  ) {
    return this.doctorService.createAccessGrant(
      body.patientId,
      user.userId,
      body.granteeId,
      user.tenantId!,
      body.reason,
      body.expiresInDays,
    );
  }

  @Get('access-grants')
  @Roles(UserRole.CLINIC_ADMIN)
  @ApiOperation({ summary: 'List all access grants' })
  async listAccessGrants(@CurrentUser() user: AuthenticatedUser) {
    return this.doctorService.listAccessGrants(user.tenantId!);
  }
}
