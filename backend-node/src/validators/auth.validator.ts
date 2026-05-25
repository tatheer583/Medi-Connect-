import Joi from 'joi';

export const loginSchema = Joi.object({
  email: Joi.string().email({ tlds: { allow: false } }).required().messages({
    'string.email': 'email must be a valid email address',
    'any.required': 'email is required',
  }),
  password: Joi.string().required().messages({
    'any.required': 'password is required',
  }),
});

export const refreshTokenSchema = Joi.object({
  refreshToken: Joi.string().required().messages({
    'any.required': 'refreshToken is required',
  }),
});

export const verifyMfaSchema = Joi.object({
  userId: Joi.string().required(),
  code: Joi.string().length(6).pattern(/^\d+$/).required().messages({
    'string.length': 'MFA code must be 6 digits',
    'string.pattern.base': 'MFA code must contain only digits',
    'any.required': 'code is required',
  }),
});

export const enableMfaSchema = Joi.object({
  method: Joi.string().valid('sms', 'email').required().messages({
    'any.only': 'method must be "sms" or "email"',
    'any.required': 'method is required',
  }),
});
