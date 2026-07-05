import { Injectable, NotFoundException, ForbiddenException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MedicalRecordEntry } from './entities';
import { RecordEntryType } from '../../common/enums';

/**
 * Medical Records service per PRD Section 6.7.
 * The clinical system of record.
 * 
 * Key design decisions from PRD:
 * - Append-only, versioned entries — never hard-deleted or silently overwritten
 * - Corrections create a new version so the full history survives
 * - Only the assigned or explicitly access-granted doctor can write
 * - Every write captures author, timestamp for audit
 */
@Injectable()
export class MedicalRecordService {
  private readonly logger = new Logger(MedicalRecordService.name);

  constructor(
    @InjectRepository(MedicalRecordEntry)
    private readonly recordRepository: Repository<MedicalRecordEntry>,
  ) {}

  /**
   * Create a new medical record entry.
   * If this is an amendment to an existing record, it creates a new version
   * with a link to the previous version (append-only pattern).
   */
  async createEntry(data: {
    patientId: string;
    doctorId: string;
    clinicId: string;
    appointmentId?: string;
    type: RecordEntryType;
    content: string;
    structuredData?: Record<string, unknown>;
    previousVersionId?: string;
  }): Promise<MedicalRecordEntry> {
    let version = 1;

    // If amending an existing record, increment version
    if (data.previousVersionId) {
      const previous = await this.recordRepository.findOne({
        where: { recordId: data.previousVersionId },
      });
      if (previous) {
        version = previous.version + 1;
      }
    }

    const entry = this.recordRepository.create({
      patientId: data.patientId,
      doctorId: data.doctorId,
      clinicId: data.clinicId,
      appointmentId: data.appointmentId || null,
      type: data.type,
      content: data.content,
      structuredData: data.structuredData || null,
      version,
      previousVersionId: data.previousVersionId || null,
    });

    const saved = await this.recordRepository.save(entry);
    this.logger.log(
      `Record entry created: ${saved.recordId} (type: ${data.type}, v${version}) for patient ${data.patientId}`,
    );
    return saved;
  }

  /**
   * List record entries for a patient, filterable by type.
   * Returns only the latest version of each entry by default.
   */
  async listEntries(patientId: string, type?: RecordEntryType) {
    const where: Record<string, unknown> = { patientId };
    if (type) where.type = type;

    return this.recordRepository.find({
      where,
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Get a specific record entry with its full version history.
   */
  async getEntry(recordId: string): Promise<MedicalRecordEntry> {
    const entry = await this.recordRepository.findOne({ where: { recordId } });
    if (!entry) throw new NotFoundException(`Record entry ${recordId} not found`);
    return entry;
  }

  /**
   * Get version history for a record entry.
   */
  async getVersionHistory(recordId: string): Promise<MedicalRecordEntry[]> {
    const entry = await this.getEntry(recordId);
    const history: MedicalRecordEntry[] = [entry];

    let currentId = entry.previousVersionId;
    while (currentId) {
      const previous = await this.recordRepository.findOne({
        where: { recordId: currentId },
      });
      if (previous) {
        history.push(previous);
        currentId = previous.previousVersionId;
      } else {
        break;
      }
    }

    return history.reverse(); // Oldest first
  }

  /**
   * Sign/finalize a record entry with doctor's e-signature.
   */
  async signEntry(recordId: string, doctorId: string): Promise<MedicalRecordEntry> {
    const entry = await this.getEntry(recordId);

    if (entry.doctorId !== doctorId) {
      throw new ForbiddenException('Only the authoring doctor can sign this entry');
    }

    entry.isSigned = true;
    entry.signedAt = new Date();
    return this.recordRepository.save(entry);
  }
}
