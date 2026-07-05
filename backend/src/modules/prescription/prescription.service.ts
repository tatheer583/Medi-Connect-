import { Injectable, NotFoundException, ForbiddenException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Prescription, PrescriptionItem } from './entities';
import { PrescriptionStatus } from '../../common/enums';

/**
 * Prescription service per PRD Section 6.8.
 * Only the Doctor role can create or finalize a prescription.
 * Controlled substances are flagged but handled as print/manual only in v1.
 */
@Injectable()
export class PrescriptionService {
  private readonly logger = new Logger(PrescriptionService.name);

  constructor(
    @InjectRepository(Prescription)
    private readonly prescriptionRepository: Repository<Prescription>,
    @InjectRepository(PrescriptionItem)
    private readonly itemRepository: Repository<PrescriptionItem>,
  ) {}

  async createPrescription(data: {
    patientId: string;
    doctorId: string;
    clinicId: string;
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
  }): Promise<Prescription> {
    const prescription = this.prescriptionRepository.create({
      patientId: data.patientId,
      doctorId: data.doctorId,
      clinicId: data.clinicId,
      recordId: data.recordId || null,
      notes: data.notes || null,
      status: PrescriptionStatus.DRAFT,
    });

    const saved = await this.prescriptionRepository.save(prescription);

    // Create prescription items
    const items = data.items.map((item) =>
      this.itemRepository.create({
        ...item,
        prescriptionId: saved.prescriptionId,
        isControlledSubstance: item.isControlledSubstance || false,
      }),
    );

    await this.itemRepository.save(items);

    this.logger.log(`Prescription created: ${saved.prescriptionId} with ${items.length} items`);

    return this.getPrescription(saved.prescriptionId);
  }

  async getPrescription(prescriptionId: string): Promise<Prescription> {
    const prescription = await this.prescriptionRepository.findOne({
      where: { prescriptionId },
      relations: { items: true },
    });

    if (!prescription) {
      throw new NotFoundException(`Prescription ${prescriptionId} not found`);
    }

    return prescription;
  }

  async finalizePrescription(prescriptionId: string, doctorId: string): Promise<Prescription> {
    const prescription = await this.getPrescription(prescriptionId);

    if (prescription.doctorId !== doctorId) {
      throw new ForbiddenException('Only the prescribing doctor can finalize');
    }

    prescription.status = PrescriptionStatus.FINALIZED;
    prescription.issuedAt = new Date();
    return this.prescriptionRepository.save(prescription);
  }

  async listByPatient(patientId: string) {
    return this.prescriptionRepository.find({
      where: { patientId },
      relations: { items: true },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Generate a downloadable/printable prescription document.
   * Returns structured data; actual PDF generation is a Phase 2 enhancement.
   */
  async downloadPrescription(prescriptionId: string) {
    const prescription = await this.getPrescription(prescriptionId);
    return {
      prescriptionId: prescription.prescriptionId,
      status: prescription.status,
      issuedAt: prescription.issuedAt,
      notes: prescription.notes,
      items: prescription.items,
      // PDF generation will be added in Phase 2
    };
  }
}
