import { Injectable, NotFoundException, ForbiddenException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import { DoctorProfile, PatientDoctorAssignment, AccessGrant } from './entities';

/**
 * Doctor service per PRD Section 6.4.
 * Manages doctor profiles, patient assignments, and access grants.
 * Every clinical-data read is checked against an active assignment or access grant.
 */
@Injectable()
export class DoctorService {
  private readonly logger = new Logger(DoctorService.name);

  constructor(
    @InjectRepository(DoctorProfile)
    private readonly doctorRepository: Repository<DoctorProfile>,
    @InjectRepository(PatientDoctorAssignment)
    private readonly assignmentRepository: Repository<PatientDoctorAssignment>,
    @InjectRepository(AccessGrant)
    private readonly grantRepository: Repository<AccessGrant>,
  ) {}

  async createProfile(data: Partial<DoctorProfile>): Promise<DoctorProfile> {
    const profile = this.doctorRepository.create(data);
    return this.doctorRepository.save(profile);
  }

  async getProfile(doctorId: string): Promise<DoctorProfile> {
    const profile = await this.doctorRepository.findOne({ where: { doctorId } });
    if (!profile) throw new NotFoundException(`Doctor profile ${doctorId} not found`);
    return profile;
  }

  async getProfileByStaffId(staffId: string): Promise<DoctorProfile | null> {
    return this.doctorRepository.findOne({ where: { staffId } });
  }

  async getAssignedPatients(doctorId: string, clinicId: string) {
    return this.assignmentRepository.find({
      where: { doctorId, clinicId, isActive: true },
      order: { assignedAt: 'DESC' },
    });
  }

  async assignPatient(patientId: string, doctorId: string, clinicId: string) {
    const existing = await this.assignmentRepository.findOne({
      where: { patientId, doctorId },
    });

    if (existing) {
      existing.isActive = true;
      return this.assignmentRepository.save(existing);
    }

    const assignment = this.assignmentRepository.create({
      patientId,
      doctorId,
      clinicId,
      assignedAt: new Date(),
    });

    return this.assignmentRepository.save(assignment);
  }

  /**
   * Check if a doctor has access to a patient's records.
   * Per PRD Section 6.4: checked against active PatientDoctorAssignment
   * or active, non-expired AccessGrant.
   */
  async hasAccessToPatient(doctorId: string, patientId: string): Promise<boolean> {
    // Check direct assignment
    const assignment = await this.assignmentRepository.findOne({
      where: { doctorId, patientId, isActive: true },
    });
    if (assignment) return true;

    // Check access grant
    const grant = await this.grantRepository.findOne({
      where: {
        granteeId: doctorId,
        patientId,
        isRevoked: false,
      },
    });

    if (grant && grant.expiresAt > new Date()) return true;

    return false;
  }

  /**
   * Create an access grant per PRD Section 6.5.
   * Time-boxed, audited, with a reason.
   */
  async createAccessGrant(
    patientId: string,
    grantorId: string,
    granteeId: string,
    clinicId: string,
    reason: string,
    expiresInDays: number = 30,
  ): Promise<AccessGrant> {
    const grant = this.grantRepository.create({
      patientId,
      grantorId,
      granteeId,
      clinicId,
      scope: 'read',
      reason,
      expiresAt: new Date(Date.now() + expiresInDays * 24 * 60 * 60 * 1000),
    });

    const saved = await this.grantRepository.save(grant);
    this.logger.log(
      `Access grant created: doctor ${granteeId} → patient ${patientId} (by ${grantorId}), expires in ${expiresInDays} days`,
    );
    return saved;
  }

  async listAccessGrants(clinicId: string) {
    return this.grantRepository.find({
      where: { clinicId },
      order: { createdAt: 'DESC' },
    });
  }
}
