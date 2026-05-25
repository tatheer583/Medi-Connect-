import { Request, Response, NextFunction } from 'express';
import { registerDoctor, registerPatient } from '../services/auth.service';
import { doctorRegistrationSchema, patientRegistrationSchema } from '../validators/user.validator';
import { createError } from '../middleware/errorHandler';
import type { RegisterDoctorDto, RegisterPatientDto } from '../models/user.model';

// ─── Register Doctor ──────────────────────────────────────────────────────────

export async function registerDoctorHandler(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { error, value } = doctorRegistrationSchema.validate(req.body, { abortEarly: false });
    if (error) {
      const messages = error.details.map((d) => d.message);
      return next(createError(messages.join('; '), 400, 'VALIDATION_ERROR'));
    }

    const dto: RegisterDoctorDto = {
      email: value.email as string,
      password: value.password as string,
      firstName: value.firstName as string,
      lastName: value.lastName as string,
      phone: value.phone as string,
      pmdcLicense: value.pmdcLicense as string,
      specialization: value.specialization as string,
      clinicName: value.clinicName as string | undefined,
      clinicAddress: value.clinicAddress as string | undefined,
    };

    const doctor = await registerDoctor(dto);

    res.status(201).json({
      success: true,
      message: 'Doctor registered successfully. Please verify your email.',
      data: {
        id: doctor.$id,
        email: doctor.email,
        userType: doctor.userType,
        firstName: doctor.firstName,
        lastName: doctor.lastName,
        isVerified: doctor.isVerified,
      },
    });
  } catch (err) {
    next(err);
  }
}

// ─── Register Patient ─────────────────────────────────────────────────────────

export async function registerPatientHandler(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { error, value } = patientRegistrationSchema.validate(req.body, { abortEarly: false });
    if (error) {
      const messages = error.details.map((d) => d.message);
      return next(createError(messages.join('; '), 400, 'VALIDATION_ERROR'));
    }

    const dto: RegisterPatientDto = {
      email: value.email as string,
      password: value.password as string,
      firstName: value.firstName as string,
      lastName: value.lastName as string,
      phone: value.phone as string,
      dateOfBirth: value.dateOfBirth as string,
      bloodGroup: value.bloodGroup as string | undefined,
      emergencyContactName: value.emergencyContactName as string | undefined,
      emergencyContactPhone: value.emergencyContactPhone as string | undefined,
    };

    const patient = await registerPatient(dto);

    res.status(201).json({
      success: true,
      message: 'Patient registered successfully. Please verify your email.',
      data: {
        id: patient.$id,
        email: patient.email,
        userType: patient.userType,
        firstName: patient.firstName,
        lastName: patient.lastName,
        isVerified: patient.isVerified,
      },
    });
  } catch (err) {
    next(err);
  }
}
