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
import { PrescriptionService } from './prescription.service';
import { Roles, CurrentUser } from '../../common/decorators';
import { RolesGuard } from '../../common/guards';
import { UserRole } from '../../common/enums';
import type { AuthenticatedUser } from '../../common/interfaces';

/**
 * Prescription controller per PRD Section 10.2.
 */
@ApiTags('Prescriptions')
@Controller('patients/:patientId/prescriptions')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@ApiBearerAuth('access-token')
export class PrescriptionController {
  constructor(private readonly prescriptionService: PrescriptionService) {}

  @Post()
  @Roles(UserRole.DOCTOR)
  @ApiOperation({ summary: 'Create a prescription' })
  async createPrescription(
    @Param('patientId') patientId: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: {
      recordId?: string;
      notes?: string;
      items: Array<{
        drug: string;
        dose: string;
        frequency: string;
        duration: string;
        instructions?: string;
        isControlledSubstance?: boolean;
      }>;
    },
  ) {
    return this.prescriptionService.createPrescription({
      patientId,
      doctorId: user.userId,
      clinicId: user.tenantId!,
      ...body,
    });
  }

  @Get()
  @Roles(UserRole.DOCTOR, UserRole.PATIENT, UserRole.NURSE)
  @ApiOperation({ summary: 'List patient prescriptions' })
  async listPrescriptions(@Param('patientId') patientId: string) {
    return this.prescriptionService.listByPatient(patientId);
  }

  @Get(':prescriptionId/download')
  @Roles(UserRole.DOCTOR, UserRole.PATIENT)
  @ApiOperation({ summary: 'Retrieve a printable prescription' })
  async downloadPrescription(@Param('prescriptionId') prescriptionId: string) {
    return this.prescriptionService.downloadPrescription(prescriptionId);
  }

  @Post(':prescriptionId/finalize')
  @Roles(UserRole.DOCTOR)
  @ApiOperation({ summary: 'Finalize a prescription' })
  async finalizePrescription(
    @Param('prescriptionId') prescriptionId: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.prescriptionService.finalizePrescription(prescriptionId, user.userId);
  }
}
