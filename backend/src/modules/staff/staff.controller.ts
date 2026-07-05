import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { StaffService } from './staff.service';
import { Roles, CurrentUser } from '../../common/decorators';
import { RolesGuard } from '../../common/guards';
import { UserRole, StaffStatus } from '../../common/enums';
import type { AuthenticatedUser } from '../../common/interfaces';

@ApiTags('Staff')
@Controller('clinics/:clinicId/staff')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@ApiBearerAuth('access-token')
export class StaffController {
  constructor(private readonly staffService: StaffService) {}

  @Post('invite')
  @Roles(UserRole.CLINIC_ADMIN)
  @ApiOperation({ summary: 'Invite a staff member' })
  async inviteStaff(
    @Param('clinicId') clinicId: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: { email: string; role: UserRole; departmentId?: string },
  ) {
    return this.staffService.inviteStaff(
      clinicId, body.email, body.role, body.departmentId || null, user.userId,
    );
  }

  @Get()
  @Roles(UserRole.CLINIC_ADMIN, UserRole.DOCTOR)
  @ApiOperation({ summary: 'List staff' })
  async listStaff(@Param('clinicId') clinicId: string) {
    return this.staffService.listStaff(clinicId);
  }

  @Patch(':staffId')
  @Roles(UserRole.CLINIC_ADMIN)
  @ApiOperation({ summary: 'Update staff role/status' })
  async updateStaff(
    @Param('staffId') staffId: string,
    @Body() body: { status?: StaffStatus; role?: UserRole },
  ) {
    if (body.status) await this.staffService.updateStaffStatus(staffId, body.status);
    if (body.role) await this.staffService.updateStaffRole(staffId, body.role);
    return { message: 'Staff updated' };
  }
}
