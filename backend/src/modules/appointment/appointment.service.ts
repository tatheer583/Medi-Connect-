import { Injectable, NotFoundException, ConflictException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, Not, In } from 'typeorm';
import { Appointment } from './entities';
import { AppointmentStatus, AppointmentType } from '../../common/enums';

/**
 * Appointment scheduling service per PRD Section 6.6.
 * Handles availability checking, booking, status transitions, and double-booking prevention.
 */
@Injectable()
export class AppointmentService {
  private readonly logger = new Logger(AppointmentService.name);

  constructor(
    @InjectRepository(Appointment)
    private readonly appointmentRepository: Repository<Appointment>,
  ) {}

  /**
   * Get available slots for a doctor on a given date.
   * Respects working hours and existing bookings per PRD Section 6.6.
   */
  async getDoctorAvailability(doctorId: string, date: string, durationMinutes: number = 30) {
    const startOfDay = new Date(`${date}T00:00:00Z`);
    const endOfDay = new Date(`${date}T23:59:59Z`);

    // Get existing bookings for the day
    const existingAppointments = await this.appointmentRepository.find({
      where: {
        doctorId,
        scheduledAt: Between(startOfDay, endOfDay),
        status: Not(In([AppointmentStatus.CANCELLED, AppointmentStatus.NO_SHOW])),
      },
      order: { scheduledAt: 'ASC' },
    });

    // Generate available slots (9AM-5PM default, configurable per clinic later)
    const slots: { start: string; end: string; available: boolean }[] = [];
    const workStart = 9; // 9 AM
    const workEnd = 17;  // 5 PM

    for (let hour = workStart; hour < workEnd; hour++) {
      for (let min = 0; min < 60; min += durationMinutes) {
        const slotStart = new Date(`${date}T${String(hour).padStart(2, '0')}:${String(min).padStart(2, '0')}:00Z`);
        const slotEnd = new Date(slotStart.getTime() + durationMinutes * 60 * 1000);

        // Check if slot conflicts with existing appointments
        const isConflict = existingAppointments.some((apt) => {
          const aptStart = new Date(apt.scheduledAt);
          const aptEnd = new Date(apt.endsAt);
          return slotStart < aptEnd && slotEnd > aptStart;
        });

        slots.push({
          start: slotStart.toISOString(),
          end: slotEnd.toISOString(),
          available: !isConflict,
        });
      }
    }

    return slots;
  }

  /**
   * Book an appointment.
   * Double-booking is prevented by checking for conflicts before insert.
   */
  async createAppointment(data: {
    patientId: string;
    doctorId: string;
    branchId: string;
    clinicId: string;
    scheduledAt: Date;
    durationMinutes?: number;
    type?: AppointmentType;
    visitReason?: string;
  }): Promise<Appointment> {
    const duration = data.durationMinutes || 30;
    const endsAt = new Date(data.scheduledAt.getTime() + duration * 60 * 1000);

    // Check for double-booking at the application level (DB exclusion constraint is the final guard)
    const conflict = await this.appointmentRepository
      .createQueryBuilder('apt')
      .where('apt.doctor_id = :doctorId', { doctorId: data.doctorId })
      .andWhere('apt.status NOT IN (:...excludedStatuses)', {
        excludedStatuses: [AppointmentStatus.CANCELLED, AppointmentStatus.NO_SHOW],
      })
      .andWhere('apt.scheduled_at < :endsAt', { endsAt })
      .andWhere('apt.ends_at > :scheduledAt', { scheduledAt: data.scheduledAt })
      .getOne();

    if (conflict) {
      throw new ConflictException('This time slot is already booked');
    }

    const appointment = this.appointmentRepository.create({
      patientId: data.patientId,
      doctorId: data.doctorId,
      branchId: data.branchId,
      clinicId: data.clinicId,
      scheduledAt: data.scheduledAt,
      endsAt,
      type: data.type || AppointmentType.IN_PERSON,
      visitReason: data.visitReason || null,
      status: AppointmentStatus.CONFIRMED,
    });

    const saved = await this.appointmentRepository.save(appointment);
    this.logger.log(`Appointment booked: ${saved.appointmentId} for patient ${data.patientId}`);
    return saved;
  }

  /**
   * Update appointment status following the lifecycle.
   * PRD: requested → confirmed → checked_in → in_progress → completed/cancelled/no_show
   */
  async updateStatus(
    appointmentId: string,
    newStatus: AppointmentStatus,
    reason?: string,
  ): Promise<Appointment> {
    const appointment = await this.appointmentRepository.findOne({
      where: { appointmentId },
    });

    if (!appointment) throw new NotFoundException(`Appointment ${appointmentId} not found`);

    // Validate status transitions
    const validTransitions: Record<AppointmentStatus, AppointmentStatus[]> = {
      [AppointmentStatus.REQUESTED]: [AppointmentStatus.CONFIRMED, AppointmentStatus.CANCELLED],
      [AppointmentStatus.CONFIRMED]: [AppointmentStatus.CHECKED_IN, AppointmentStatus.CANCELLED, AppointmentStatus.NO_SHOW],
      [AppointmentStatus.CHECKED_IN]: [AppointmentStatus.IN_PROGRESS, AppointmentStatus.CANCELLED],
      [AppointmentStatus.IN_PROGRESS]: [AppointmentStatus.COMPLETED, AppointmentStatus.CANCELLED],
      [AppointmentStatus.COMPLETED]: [],
      [AppointmentStatus.CANCELLED]: [],
      [AppointmentStatus.NO_SHOW]: [],
    };

    if (!validTransitions[appointment.status]?.includes(newStatus)) {
      throw new BadRequestException(
        `Cannot transition from ${appointment.status} to ${newStatus}`,
      );
    }

    appointment.status = newStatus;

    if (newStatus === AppointmentStatus.CHECKED_IN) {
      appointment.checkedInAt = new Date();
    }
    if (newStatus === AppointmentStatus.CANCELLED) {
      appointment.cancelledAt = new Date();
      appointment.cancellationReason = reason || null;
    }

    return this.appointmentRepository.save(appointment);
  }

  async getAppointment(appointmentId: string): Promise<Appointment> {
    const apt = await this.appointmentRepository.findOne({ where: { appointmentId } });
    if (!apt) throw new NotFoundException(`Appointment ${appointmentId} not found`);
    return apt;
  }

  async listByPatient(patientId: string) {
    return this.appointmentRepository.find({
      where: { patientId },
      order: { scheduledAt: 'DESC' },
    });
  }

  async listByDoctor(doctorId: string, date?: string) {
    const where: Record<string, unknown> = { doctorId };

    if (date) {
      const startOfDay = new Date(`${date}T00:00:00Z`);
      const endOfDay = new Date(`${date}T23:59:59Z`);
      where.scheduledAt = Between(startOfDay, endOfDay);
    }

    return this.appointmentRepository.find({
      where,
      order: { scheduledAt: 'ASC' },
    });
  }

  async getBranchQueue(branchId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    return this.appointmentRepository.find({
      where: {
        branchId,
        scheduledAt: Between(today, tomorrow),
        status: In([AppointmentStatus.CONFIRMED, AppointmentStatus.CHECKED_IN, AppointmentStatus.IN_PROGRESS]),
      },
      order: { scheduledAt: 'ASC' },
    });
  }
}
