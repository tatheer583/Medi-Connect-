import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Clinic, Branch, Department } from './entities';
import { CreateClinicDto, UpdateClinicDto, CreateBranchDto, CreateDepartmentDto } from './dto';
import { ClinicStatus } from '../../common/enums';

/**
 * Clinic management service per PRD Section 6.2.
 * Handles clinic CRUD, branches, and departments.
 * Clinics are never hard-deleted, only suspended/archived.
 */
@Injectable()
export class ClinicService {
  private readonly logger = new Logger(ClinicService.name);

  constructor(
    @InjectRepository(Clinic)
    private readonly clinicRepository: Repository<Clinic>,
    @InjectRepository(Branch)
    private readonly branchRepository: Repository<Branch>,
    @InjectRepository(Department)
    private readonly departmentRepository: Repository<Department>,
  ) {}

  // ─── Clinic CRUD ────────────────────────────────────────────────────────────

  async createClinic(dto: CreateClinicDto): Promise<Clinic> {
    const clinic = this.clinicRepository.create({
      ...dto,
      status: ClinicStatus.PENDING,
    });

    const saved = await this.clinicRepository.save(clinic);
    this.logger.log(`Clinic created: ${saved.name} (${saved.clinicId})`);
    return saved;
  }

  async getClinic(clinicId: string): Promise<Clinic> {
    const clinic = await this.clinicRepository.findOne({
      where: { clinicId },
      relations: { branches: { departments: true } },
    });

    if (!clinic) {
      throw new NotFoundException(`Clinic ${clinicId} not found`);
    }

    return clinic;
  }

  async updateClinic(clinicId: string, dto: UpdateClinicDto): Promise<Clinic> {
    const clinic = await this.getClinic(clinicId);
    Object.assign(clinic, dto);
    return this.clinicRepository.save(clinic);
  }

  async listClinics(page: number = 1, limit: number = 20) {
    const [clinics, total] = await this.clinicRepository.findAndCount({
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    });

    return {
      data: clinics,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  // ─── Branch CRUD ────────────────────────────────────────────────────────────

  async createBranch(clinicId: string, dto: CreateBranchDto): Promise<Branch> {
    // Verify clinic exists
    await this.getClinic(clinicId);

    const branch = this.branchRepository.create({
      ...dto,
      clinicId,
    });

    const saved = await this.branchRepository.save(branch);
    this.logger.log(`Branch created: ${saved.name} for clinic ${clinicId}`);
    return saved;
  }

  async listBranches(clinicId: string) {
    return this.branchRepository.find({
      where: { clinicId },
      relations: { departments: true },
      order: { createdAt: 'ASC' },
    });
  }

  async getBranch(branchId: string): Promise<Branch> {
    const branch = await this.branchRepository.findOne({
      where: { branchId },
      relations: { departments: true },
    });

    if (!branch) {
      throw new NotFoundException(`Branch ${branchId} not found`);
    }

    return branch;
  }

  // ─── Department CRUD ────────────────────────────────────────────────────────

  async createDepartment(branchId: string, dto: CreateDepartmentDto): Promise<Department> {
    await this.getBranch(branchId);

    const department = this.departmentRepository.create({
      ...dto,
      branchId,
    });

    const saved = await this.departmentRepository.save(department);
    this.logger.log(`Department created: ${saved.name} for branch ${branchId}`);
    return saved;
  }

  async listDepartments(branchId: string) {
    return this.departmentRepository.find({
      where: { branchId },
      order: { name: 'ASC' },
    });
  }
}
