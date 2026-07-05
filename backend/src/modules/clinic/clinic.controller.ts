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
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { ClinicService } from './clinic.service';
import { CreateClinicDto, UpdateClinicDto, CreateBranchDto, CreateDepartmentDto } from './dto';
import { Roles } from '../../common/decorators';
import { RolesGuard, TenantGuard } from '../../common/guards';
import { UserRole } from '../../common/enums';
import { PaginationDto } from '../../common/dto';

/**
 * Clinic & Branch Management controller per PRD Section 10.2.
 */
@ApiTags('Clinics')
@Controller('clinics')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@ApiBearerAuth('access-token')
export class ClinicController {
  constructor(private readonly clinicService: ClinicService) {}

  @Post()
  @Roles(UserRole.SUPER_ADMIN, UserRole.CLINIC_ADMIN)
  @ApiOperation({ summary: 'Create clinic (onboarding)' })
  @ApiResponse({ status: 201, description: 'Clinic created' })
  async createClinic(@Body() dto: CreateClinicDto) {
    return this.clinicService.createClinic(dto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get clinic profile' })
  async getClinic(@Param('id') id: string) {
    return this.clinicService.getClinic(id);
  }

  @Patch(':id')
  @Roles(UserRole.SUPER_ADMIN, UserRole.CLINIC_ADMIN)
  @ApiOperation({ summary: 'Update clinic profile' })
  async updateClinic(@Param('id') id: string, @Body() dto: UpdateClinicDto) {
    return this.clinicService.updateClinic(id, dto);
  }

  // ─── Branches ───────────────────────────────────────────────────────────────

  @Get(':id/branches')
  @ApiOperation({ summary: 'List branches' })
  async listBranches(@Param('id') clinicId: string) {
    return this.clinicService.listBranches(clinicId);
  }

  @Post(':id/branches')
  @Roles(UserRole.SUPER_ADMIN, UserRole.CLINIC_ADMIN)
  @ApiOperation({ summary: 'Create branch' })
  async createBranch(@Param('id') clinicId: string, @Body() dto: CreateBranchDto) {
    return this.clinicService.createBranch(clinicId, dto);
  }

  // ─── Departments ────────────────────────────────────────────────────────────

  @Get('branches/:branchId/departments')
  @ApiOperation({ summary: 'List departments' })
  async listDepartments(@Param('branchId') branchId: string) {
    return this.clinicService.listDepartments(branchId);
  }

  @Post('branches/:branchId/departments')
  @Roles(UserRole.SUPER_ADMIN, UserRole.CLINIC_ADMIN)
  @ApiOperation({ summary: 'Create department' })
  async createDepartment(
    @Param('branchId') branchId: string,
    @Body() dto: CreateDepartmentDto,
  ) {
    return this.clinicService.createDepartment(branchId, dto);
  }
}
