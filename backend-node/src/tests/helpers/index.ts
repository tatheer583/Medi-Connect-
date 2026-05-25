/**
 * Test helper utilities — shared across unit and integration tests.
 */

import { expect } from '@jest/globals';

// ─── Request helpers ──────────────────────────────────────────────────────────

/**
 * Build a minimal valid doctor registration payload.
 * Override individual fields to test specific scenarios.
 */
export function buildDoctorPayload(overrides: Record<string, unknown> = {}): Record<string, unknown> {
  return {
    email: 'doctor@example.com',
    password: 'SecurePass123!',
    firstName: 'Ahmed',
    lastName: 'Khan',
    role: 'doctor',
    pmdcLicense: 'PMDC-12345',
    specialization: 'General Physician',
    phone: '+923001234567',
    ...overrides,
  };
}

/**
 * Build a minimal valid patient registration payload.
 * Override individual fields to test specific scenarios.
 */
export function buildPatientPayload(overrides: Record<string, unknown> = {}): Record<string, unknown> {
  return {
    email: 'patient@example.com',
    password: 'SecurePass123!',
    firstName: 'Sara',
    lastName: 'Ali',
    role: 'patient',
    dateOfBirth: '1990-05-15',
    phone: '+923009876543',
    ...overrides,
  };
}

// ─── Assertion helpers ────────────────────────────────────────────────────────

/**
 * Assert that a Joi validation result has errors on the specified fields.
 */
export function expectValidationErrors(
  errors: string[] | undefined,
  expectedFields: string[],
): void {
  expect(errors).toBeDefined();
  for (const field of expectedFields) {
    expect(errors?.some((e) => e.includes(field))).toBe(true);
  }
}
