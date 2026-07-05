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
import { AppointmentService } from './appointment.service';
import { Roles, CurrentUser } from '../../common/decorators';
import { RolesGuard } from '../../common/guards';
import { UserRole, AppointmentStatus, AppointmentType } from '../../common/enums';
import type { AuthenticatedUser } from '../../common/interfaces';

/**
 * Appointment controller per PRD Section 10.2.
 */
@ApiTags('Appointments')
@Controller()
@UseGuards(AuthGuard('jwt'), RolesGuard)
@ApiBearerAuth('access-token')
export class AppointmentController {
  constructor(private readonly appointmentService: AppointmentService) {}

  @Get('doctors/:id/availability')
  @ApiOperation({ summary: 'Get available slots for a doctor' })
  async getDoctorAvailability(
    @Param('id') doctorId: string,
    @Query('date') date: string,
    @Query('duration') duration?: number,
  ) {
    return this.appointmentService.getDoctorAvailability(doctorId, date, duration);
  }

  @Post('appointments')
  @Roles(UserRole.PATIENT, UserRole.RECEPTIONIST, UserRole.CLINIC_ADMIN, UserRole.DOCTOR)
  @ApiOperation({ summary: 'Book an appointment' })
  async createAppointment(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: {
      patientId: string;
      doctorId: string;
      branchId: string;
      scheduledAt: string;
      durationMinutes?: number;
      type?: AppointmentType;
      visitReason?: string;
    },
  ) {
    return this.appointmentService.createAppointment({
      ...body,
      clinicId: user.tenantId!,
      scheduledAt: new Date(body.scheduledAt),
    });
  }

  @Patch('appointments/:id/status')
  @Roles(UserRole.DOCTOR, UserRole.RECEPTIONIST, UserRole.CLINIC_ADMIN, UserRole.PATIENT)
  @ApiOperation({ summary: 'Update appointment status (check-in, complete, cancel)' })
  async updateStatus(
    @Param('id') appointmentId: string,
    @Body() body: { status: AppointmentStatus; reason?: string },
  ) {
    return this.appointmentService.updateStatus(appointmentId, body.status, body.reason);
  }

  @Get('appointments/:id')
  @ApiOperation({ summary: 'Get appointment details' })
  async getAppointment(@Param('id') id: string) {
    return this.appointmentService.getAppointment(id);
  }

  @Get('branches/:id/queue')
  @Roles(UserRole.DOCTOR, UserRole.RECEPTIONIST, UserRole.CLINIC_ADMIN, UserRole.NURSE)
  @ApiOperation({ summary: 'Live queue state for a branch' })
  async getBranchQueue(@Param('id') branchId: string) {
    return this.appointmentService.getBranchQueue(branchId);
  }
}
