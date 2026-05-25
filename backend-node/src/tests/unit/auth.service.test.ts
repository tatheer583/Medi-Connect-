/**
 * Unit tests for auth service registration validation logic.
 * Appwrite calls are mocked — no real network requests.
 *
 * Validates: Requirements 1.1, 1.2, 1.5, 12.1
 */

import { doctorRegistrationSchema, patientRegistrationSchema, validate } from '../../validators/user.validator';

// ─── Doctor Registration Validation ──────────────────────────────────────────

describe('Doctor registration validation', () => {
  const validDoctor = {
    email: 'dr.ahmed@clinic.com',
    password: 'SecurePass1!',
    firstName: 'Ahmed',
    lastName: 'Raza',
    role: 'doctor',
    pmdcLicense: 'PMDC-12345',
    specialization: 'General Physician',
    phone: '+923001234567',
  };

  it('accepts a fully valid doctor payload', () => {
    const result = validate(doctorRegistrationSchema, validDoctor);
    expect(result.valid).toBe(true);
  });

  it('rejects missing email', () => {
    const { email: _email, ...rest } = validDoctor;
    const result = validate(doctorRegistrationSchema, rest);
    expect(result.valid).toBe(false);
    expect(result.errors?.some((e) => e.includes('email'))).toBe(true);
  });

  it('rejects invalid email format', () => {
    const result = validate(doctorRegistrationSchema, { ...validDoctor, email: 'not-an-email' });
    expect(result.valid).toBe(false);
  });

  it('rejects weak password (no uppercase)', () => {
    const result = validate(doctorRegistrationSchema, { ...validDoctor, password: 'weakpass1!' });
    expect(result.valid).toBe(false);
  });

  it('rejects invalid PMDC license format', () => {
    const result = validate(doctorRegistrationSchema, { ...validDoctor, pmdcLicense: 'INVALID' });
    expect(result.valid).toBe(false);
  });

  it('rejects missing specialization', () => {
    const { specialization: _s, ...rest } = validDoctor;
    const result = validate(doctorRegistrationSchema, rest);
    expect(result.valid).toBe(false);
  });

  it('accepts optional clinic fields when provided', () => {
    const result = validate(doctorRegistrationSchema, {
      ...validDoctor,
      clinicName: 'City Clinic',
      clinicAddress: '123 Main St',
    });
    expect(result.valid).toBe(true);
  });
});

// ─── Patient Registration Validation ─────────────────────────────────────────

describe('Patient registration validation', () => {
  const validPatient = {
    email: 'fatima@example.com',
    password: 'SecurePass1!',
    firstName: 'Fatima',
    lastName: 'Khan',
    role: 'patient',
    dateOfBirth: '1982-05-15',
    phone: '+923009876543',
  };

  it('accepts a fully valid patient payload', () => {
    const result = validate(patientRegistrationSchema, validPatient);
    expect(result.valid).toBe(true);
  });

  it('rejects missing dateOfBirth', () => {
    const { dateOfBirth: _d, ...rest } = validPatient;
    const result = validate(patientRegistrationSchema, rest);
    expect(result.valid).toBe(false);
  });

  it('rejects invalid dateOfBirth format', () => {
    const result = validate(patientRegistrationSchema, { ...validPatient, dateOfBirth: '15-05-1982' });
    expect(result.valid).toBe(false);
  });

  it('rejects invalid blood group', () => {
    const result = validate(patientRegistrationSchema, { ...validPatient, bloodGroup: 'X+' });
    expect(result.valid).toBe(false);
  });

  it('accepts valid blood group', () => {
    const result = validate(patientRegistrationSchema, { ...validPatient, bloodGroup: 'O+' });
    expect(result.valid).toBe(true);
  });

  it('rejects missing phone', () => {
    const { phone: _p, ...rest } = validPatient;
    const result = validate(patientRegistrationSchema, rest);
    expect(result.valid).toBe(false);
  });
});
