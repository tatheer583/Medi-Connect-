/**
 * Property-based tests for user registration validation.
 *
 * **Validates: Requirements 12.1, 13.1**
 *
 * Properties tested:
 *   P1 — Valid doctor registration data always passes validation
 *   P2 — Valid patient registration data always passes validation
 *   P3 — Doctor data with any required field missing always fails validation
 *   P4 — Patient data with any required field missing always fails validation
 */

import * as fc from 'fast-check';
import {
  doctorRegistrationSchema,
  patientRegistrationSchema,
  validate,
} from '../../validators/user.validator';

// ─── Arbitraries ──────────────────────────────────────────────────────────────

/** Generates a valid email address */
const validEmail = fc
  .tuple(
    fc.stringMatching(/^[a-z]{3,10}$/),
    fc.stringMatching(/^[a-z]{3,8}$/),
    fc.constantFrom('com', 'net', 'org', 'io'),
  )
  .map(([user, domain, tld]) => `${user}@${domain}.${tld}`);

/** Generates a password that satisfies all rules */
const validPassword = fc
  .tuple(
    fc.stringMatching(/^[a-z]{3,6}$/),
    fc.stringMatching(/^[A-Z]{2,4}$/),
    fc.integer({ min: 10, max: 99 }).map(String),
    fc.constantFrom('!', '@', '#', '$', '%'),
  )
  .map(([lower, upper, digits, special]) => `${lower}${upper}${digits}${special}`);

/** Generates a valid name (1–50 non-empty chars) */
const validName = fc.stringMatching(/^[A-Za-z]{2,20}$/);

/** Generates a valid international phone number */
const validPhone = fc
  .integer({ min: 1000000000, max: 9999999999 })
  .map((n) => `+92${n}`);

/** Generates a valid PMDC license */
const validPmdcLicense = fc
  .integer({ min: 1000, max: 999999 })
  .map((n) => `PMDC-${n}`);

/** Generates a valid ISO date of birth (1940–2005) */
const validDateOfBirth = fc
  .integer({ min: new Date('1940-01-01').getTime(), max: new Date('2005-12-31').getTime() })
  .map((ms) => new Date(ms).toISOString().split('T')[0] as string);

/** Generates a complete valid doctor payload */
const validDoctorPayload = fc.record({
  email: validEmail,
  password: validPassword,
  firstName: validName,
  lastName: validName,
  role: fc.constant('doctor' as const),
  pmdcLicense: validPmdcLicense,
  specialization: fc.constantFrom(
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Neurologist',
  ),
  phone: validPhone,
});

/** Generates a complete valid patient payload */
const validPatientPayload = fc.record({
  email: validEmail,
  password: validPassword,
  firstName: validName,
  lastName: validName,
  role: fc.constant('patient' as const),
  dateOfBirth: validDateOfBirth,
  phone: validPhone,
});

// ─── P1: Valid doctor data always passes ──────────────────────────────────────

describe('P1 — Valid doctor registration data always passes validation', () => {
  /**
   * **Validates: Requirements 12.1, 13.1**
   * For any well-formed doctor payload, validation must succeed.
   */
  it('should pass for all valid doctor payloads', () => {
    fc.assert(
      fc.property(validDoctorPayload, (payload) => {
        const result = validate(doctorRegistrationSchema, payload);
        expect(result.valid).toBe(true);
        expect(result.errors).toBeUndefined();
      }),
      { numRuns: 100 },
    );
  });
});

// ─── P2: Valid patient data always passes ─────────────────────────────────────

describe('P2 — Valid patient registration data always passes validation', () => {
  /**
   * **Validates: Requirements 12.1, 13.1**
   * For any well-formed patient payload, validation must succeed.
   */
  it('should pass for all valid patient payloads', () => {
    fc.assert(
      fc.property(validPatientPayload, (payload) => {
        const result = validate(patientRegistrationSchema, payload);
        expect(result.valid).toBe(true);
        expect(result.errors).toBeUndefined();
      }),
      { numRuns: 100 },
    );
  });
});

// ─── P3: Doctor data with missing required field always fails ─────────────────

describe('P3 — Doctor data with any required field missing always fails validation', () => {
  /**
   * **Validates: Requirements 12.1, 13.1**
   * Removing any required field from a valid doctor payload must cause validation to fail.
   */
  const doctorRequiredFields = [
    'email',
    'password',
    'firstName',
    'lastName',
    'role',
    'pmdcLicense',
    'specialization',
    'phone',
  ] as const;

  it.each(doctorRequiredFields)(
    'should fail when "%s" is missing',
    (field) => {
      fc.assert(
        fc.property(validDoctorPayload, (payload) => {
          const incomplete = { ...payload };
          delete (incomplete as Record<string, unknown>)[field];

          const result = validate(doctorRegistrationSchema, incomplete);
          expect(result.valid).toBe(false);
          expect(result.errors).toBeDefined();
          expect(result.errors!.length).toBeGreaterThan(0);
        }),
        { numRuns: 50 },
      );
    },
  );
});

// ─── P4: Patient data with missing required field always fails ────────────────

describe('P4 — Patient data with any required field missing always fails validation', () => {
  /**
   * **Validates: Requirements 12.1, 13.1**
   * Removing any required field from a valid patient payload must cause validation to fail.
   */
  const patientRequiredFields = [
    'email',
    'password',
    'firstName',
    'lastName',
    'role',
    'dateOfBirth',
    'phone',
  ] as const;

  it.each(patientRequiredFields)(
    'should fail when "%s" is missing',
    (field) => {
      fc.assert(
        fc.property(validPatientPayload, (payload) => {
          const incomplete = { ...payload };
          delete (incomplete as Record<string, unknown>)[field];

          const result = validate(patientRegistrationSchema, incomplete);
          expect(result.valid).toBe(false);
          expect(result.errors).toBeDefined();
          expect(result.errors!.length).toBeGreaterThan(0);
        }),
        { numRuns: 50 },
      );
    },
  );
});
