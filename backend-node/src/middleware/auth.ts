import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { createError } from './errorHandler';

export type UserRole = 'doctor' | 'patient' | 'lab_technician' | 'admin';

export interface JwtPayload {
  userId: string;
  email: string;
  role: UserRole;
  iat?: number;
  exp?: number;
}

// Extend Express Request to include authenticated user
declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload;
    }
  }
}

/**
 * JWT authentication middleware.
 * Validates the Bearer token from the Authorization header and
 * attaches the decoded payload to req.user.
 */
export function authenticate(req: Request, _res: Response, next: NextFunction): void {
  const authHeader = req.headers['authorization'];

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(createError('No authentication token provided', 401, 'UNAUTHORIZED'));
  }

  const token = authHeader.slice(7); // Remove "Bearer " prefix
  const secret = process.env['JWT_SECRET'];

  if (!secret) {
    return next(createError('JWT secret not configured', 500, 'SERVER_ERROR'));
  }

  try {
    const decoded = jwt.verify(token, secret) as JwtPayload;
    req.user = decoded;
    next();
  } catch (err) {
    if (err instanceof jwt.TokenExpiredError) {
      return next(createError('Authentication token has expired', 401, 'TOKEN_EXPIRED'));
    }
    if (err instanceof jwt.JsonWebTokenError) {
      return next(createError('Invalid authentication token', 401, 'INVALID_TOKEN'));
    }
    next(createError('Authentication failed', 401, 'AUTH_FAILED'));
  }
}

/**
 * Role-based authorization middleware factory.
 * Use after `authenticate` to restrict access to specific roles.
 *
 * @example
 * router.get('/admin', authenticate, authorize('admin'), handler)
 * router.get('/records', authenticate, authorize('doctor', 'admin'), handler)
 */
export function authorize(...allowedRoles: UserRole[]) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) {
      return next(createError('User not authenticated', 401, 'UNAUTHORIZED'));
    }

    if (!allowedRoles.includes(req.user.role)) {
      return next(
        createError(
          `Access denied. Required roles: ${allowedRoles.join(', ')}`,
          403,
          'FORBIDDEN'
        )
      );
    }

    next();
  };
}

/**
 * Generates a JWT access token.
 */
export function generateToken(payload: Omit<JwtPayload, 'iat' | 'exp'>): string {
  const secret = process.env['JWT_SECRET'];
  if (!secret) throw new Error('JWT_SECRET is not configured');

  const expiresIn = process.env['JWT_EXPIRES_IN'] ?? '7d';
  return jwt.sign(payload, secret, { expiresIn } as jwt.SignOptions);
}

/**
 * Generates a JWT refresh token.
 */
export function generateRefreshToken(payload: Omit<JwtPayload, 'iat' | 'exp'>): string {
  const secret = process.env['JWT_REFRESH_SECRET'];
  if (!secret) throw new Error('JWT_REFRESH_SECRET is not configured');

  const expiresIn = process.env['JWT_REFRESH_EXPIRES_IN'] ?? '30d';
  return jwt.sign(payload, secret, { expiresIn } as jwt.SignOptions);
}
