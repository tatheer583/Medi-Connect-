import Joi from 'joi';

// ─── Shared field rules ───────────────────────────────────────────────────────

const emailRule = Joi.string().email({ tlds: { allow: false } }).required().messages({
  'string.email': 'email must be a valid email address',
  'any.required': 'email is required',
});

const passwordRule = Joi.string()
  .min(8)
  .max(128)
  .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])/)
  .required()
  .messages({
    'string.min': 'password must be at least 8 characters',
    'string.pattern.base':
      'password must contain uppercase, lowercase, a digit, and a special character',
    'any.required': 'password is required',
  });

const firstNameRule = Joi.string().trim().min(1).max(50).required().messages({
  'any.required': 'firstName is required',
  'string.empty': 'firstName cannot be empty',
});

const lastNameRule = Joi.string().trim().min(1).max(50).required().messages({
  'any.required': 'lastName is required',
  'string.empty': 'lastName cannot be empty',
});

const phoneRule = Joi.string()
  .pattern(/^\+?[1-9]\d{6,14}$/)
  .required()
  .messages({
    'string.pattern.base': 'phone must be a valid international phone number',
    'any.required': 'phone is required',
  });

// ─── Doctor registration schema ───────────────────────────────────────────────

export const doctorRegistrationSchema = Joi.object({
  email: emailRule,
  password: passwordRule,
  firstName: firstNameRule,
  lastName: lastNameRule,
  role: Joi.string().valid('doctor').required().messages({
    'any.only': 'role must be "doctor"',
    'any.required': 'role is required',
  }),
  pmdcLicense: Joi.string()
    .pattern(/^PMDC-\d{4,10}$/)
    .required()
    .messages({
      'string.pattern.base': 'pmdcLicense must follow the format PMDC-XXXXX',
      'any.required': 'pmdcLicense is required',
    }),
  specialization: Joi.string().trim().min(2).max(100).required().messages({
    'any.required': 'specialization is required',
  }),
  phone: phoneRule,
  clinicName: Joi.string().trim().max(100).optional(),
  clinicAddress: Joi.string().trim().max(255).optional(),
});

// ─── Patient registration schema ──────────────────────────────────────────────

export const patientRegistrationSchema = Joi.object({
  email: emailRule,
  password: passwordRule,
  firstName: firstNameRule,
  lastName: lastNameRule,
  role: Joi.string().valid('patient').required().messages({
    'any.only': 'role must be "patient"',
    'any.required': 'role is required',
  }),
  dateOfBirth: Joi.string()
    .isoDate()
    .required()
    .messages({
      'string.isoDate': 'dateOfBirth must be a valid ISO date (YYYY-MM-DD)',
      'any.required': 'dateOfBirth is required',
    }),
  phone: phoneRule,
  bloodGroup: Joi.string()
    .valid('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')
    .optional(),
  emergencyContactName: Joi.string().trim().max(100).optional(),
  emergencyContactPhone: Joi.string()
    .pattern(/^\+?[1-9]\d{6,14}$/)
    .optional(),
});

// ─── Validation helper ────────────────────────────────────────────────────────

export interface ValidationResult {
  valid: boolean;
  errors?: string[];
}

/**
 * Validate data against a Joi schema and return a structured result.
 */
export function validate(
  schema: Joi.ObjectSchema,
  data: unknown,
): ValidationResult {
  const { error } = schema.validate(data, { abortEarly: false });
  if (!error) {
    return { valid: true };
  }
  return {
    valid: false,
    errors: error.details.map((d) => d.message),
  };
}
