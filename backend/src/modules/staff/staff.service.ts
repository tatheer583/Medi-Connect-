import { Injectable, NotFoundException, ConflictException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import { StaffMember, StaffInvite } from './entities';
import { UserRole, StaffStatus } from '../../common/enums';

@Injectable()
export class StaffService {
  private readonly logger = new Logger(StaffService.name);

  constructor(
    @InjectRepository(StaffMember)
    private readonly staffRepository: Repository<StaffMember>,
    @InjectRepository(StaffInvite)
    private readonly inviteRepository: Repository<StaffInvite>,
  ) {}

  async inviteStaff(clinicId: string, email: string, role: UserRole, departmentId: string | null, invitedBy: string) {
    // Validate role — only clinic staff roles can be invited
    const validRoles = [UserRole.DOCTOR, UserRole.NURSE, UserRole.RECEPTIONIST, UserRole.AGENT];
    if (!validRoles.includes(role)) {
      throw new BadRequestException(`Invalid staff role: ${role}`);
    }

    const inviteToken = uuidv4();
    const inviteTokenHash = await bcrypt.hash(inviteToken, 12);

    const invite = this.inviteRepository.create({
      clinicId,
      email: email.toLowerCase(),
      role,
      departmentId,
      inviteTokenHash,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
      invitedBy,
    });

    await this.inviteRepository.save(invite);
    this.logger.log(`Staff invite sent to ${email} for clinic ${clinicId} (role: ${role})`);

    // TODO: Send invite email (Phase 2)
    return { message: 'Invite sent', inviteToken }; // Token returned for dev; emailed in production
  }

  async listStaff(clinicId: string) {
    return this.staffRepository.find({
      where: { clinicId },
      order: { createdAt: 'DESC' },
    });
  }

  async updateStaffStatus(staffId: string, status: StaffStatus) {
    const staff = await this.staffRepository.findOne({ where: { staffId } });
    if (!staff) throw new NotFoundException(`Staff member ${staffId} not found`);

    staff.status = status;
    return this.staffRepository.save(staff);
  }

  async updateStaffRole(staffId: string, role: UserRole) {
    const staff = await this.staffRepository.findOne({ where: { staffId } });
    if (!staff) throw new NotFoundException(`Staff member ${staffId} not found`);

    staff.roleEnum = role;
    return this.staffRepository.save(staff);
  }
}
