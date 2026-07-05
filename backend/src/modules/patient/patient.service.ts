import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PatientProfile, EmergencyContact, InsuranceInfo } from './entities';

/**
 * Patient management service per PRD Section 6.5.
 * Central patient identity and self-service portal.
 * A patient record belongs to exactly one clinic tenant by default.
 */
@Injectable()
export class PatientService {
  private readonly logger = new Logger(PatientService.name);

  constructor(
    @InjectRepository(PatientProfile)
    private readonly patientRepository: Repository<PatientProfile>,
    @InjectRepository(EmergencyContact)
    private readonly emergencyContactRepository: Repository<EmergencyContact>,
    @InjectRepository(InsuranceInfo)
    private readonly insuranceRepository: Repository<InsuranceInfo>,
  ) {}

  async createPatient(data: Partial<PatientProfile>): Promise<PatientProfile> {
    const patient = this.patientRepository.create(data);
    const saved = await this.patientRepository.save(patient);
    this.logger.log(`Patient created: ${saved.firstName} ${saved.lastName} (${saved.patientId})`);
    return saved;
  }

  async getPatient(patientId: string): Promise<PatientProfile> {
    const patient = await this.patientRepository.findOne({ where: { patientId } });
    if (!patient) throw new NotFoundException(`Patient ${patientId} not found`);
    return patient;
  }

  async updatePatient(patientId: string, data: Partial<PatientProfile>): Promise<PatientProfile> {
    const patient = await this.getPatient(patientId);
    Object.assign(patient, data);
    return this.patientRepository.save(patient);
  }

  async listPatients(clinicId: string, page: number = 1, limit: number = 20) {
    const [patients, total] = await this.patientRepository.findAndCount({
      where: { clinicId },
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    });

    return {
      data: patients,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async getPatientByUserId(userId: string): Promise<PatientProfile | null> {
    return this.patientRepository.findOne({ where: { userId } });
  }

  // ─── Emergency Contacts ─────────────────────────────────────────────────────

  async addEmergencyContact(patientId: string, clinicId: string, data: Partial<EmergencyContact>) {
    const contact = this.emergencyContactRepository.create({
      ...data,
      patientId,
      clinicId,
    });
    return this.emergencyContactRepository.save(contact);
  }

  async getEmergencyContacts(patientId: string) {
    return this.emergencyContactRepository.find({ where: { patientId } });
  }

  // ─── Insurance ──────────────────────────────────────────────────────────────

  async addInsurance(patientId: string, clinicId: string, data: Partial<InsuranceInfo>) {
    const insurance = this.insuranceRepository.create({
      ...data,
      patientId,
      clinicId,
    });
    return this.insuranceRepository.save(insurance);
  }

  async getInsurance(patientId: string) {
    return this.insuranceRepository.find({ where: { patientId } });
  }

  /**
   * Get patient timeline — chronological health timeline per PRD Section 6.5.
   * Returns a unified view of appointments, records, prescriptions.
   * Actual implementation will join across modules; stub here for Phase 1.
   */
  async getTimeline(patientId: string) {
    const patient = await this.getPatient(patientId);
    return {
      patientId: patient.patientId,
      name: `${patient.firstName} ${patient.lastName}`,
      timeline: [], // Will be populated when cross-module queries are built
    };
  }
}
