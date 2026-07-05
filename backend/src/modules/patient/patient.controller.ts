import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PatientService } from './patient.service';
import { Roles, CurrentUser } from '../../common/decorators';
import { RolesGuard } from '../../common/guards';
import { UserRole } from '../../common/enums';
import type { AuthenticatedUser } from '../../common/interfaces';

/**
 * Patient controller per PRD Section 10.2.
 */
@ApiTags('Patients')
@Controller('patients')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@ApiBearerAuth('access-token')
export class PatientController {
  constructor(private readonly patientService: PatientService) {}

  @Post()
  @Roles(UserRole.CLINIC_ADMIN, UserRole.DOCTOR, UserRole.RECEPTIONIST)
  @ApiOperation({ summary: 'Register a patient' })
  async createPatient(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: {
      firstName: string;
      lastName: string;
      dateOfBirth: string;
      gender?: string;
      phone?: string;
      address?: string;
      bloodType?: string;
    },
  ) {
    return this.patientService.createPatient({
      ...body,
      dateOfBirth: new Date(body.dateOfBirth),
      clinicId: user.tenantId!,
      userId: user.userId,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get patient profile' })
  async getPatient(@Param('id') id: string) {
    return this.patientService.getPatient(id);
  }

  @Patch(':id')
  @Roles(UserRole.CLINIC_ADMIN, UserRole.DOCTOR, UserRole.PATIENT)
  @ApiOperation({ summary: 'Update patient profile' })
  async updatePatient(
    @Param('id') id: string,
    @Body() body: Partial<{ firstName: string; lastName: string; phone: string; address: string }>,
  ) {
    return this.patientService.updatePatient(id, body);
  }

  @Get(':id/timeline')
  @ApiOperation({ summary: 'Chronological health timeline' })
  async getTimeline(@Param('id') id: string) {
    return this.patientService.getTimeline(id);
  }

  @Post(':id/emergency-contacts')
  @Roles(UserRole.CLINIC_ADMIN, UserRole.DOCTOR, UserRole.PATIENT)
  @ApiOperation({ summary: 'Add emergency contact' })
  async addEmergencyContact(
    @Param('id') patientId: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: { name: string; relationship: string; phone: string; email?: string },
  ) {
    return this.patientService.addEmergencyContact(patientId, user.tenantId!, body);
  }

  @Get(':id/emergency-contacts')
  @ApiOperation({ summary: 'List emergency contacts' })
  async getEmergencyContacts(@Param('id') patientId: string) {
    return this.patientService.getEmergencyContacts(patientId);
  }
}
