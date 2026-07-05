import { UserRole } from '../enums';

/**
 * JWT payload structure.
 * tenant_id, role, and user_id are signed claims per PRD Section 5.2.
 */
export interface JwtPayload {
  sub: string;       // user_id
  email: string;
  role: UserRole;
  tenantId: string | null;  // null for SuperAdmin
  iat?: number;
  exp?: number;
}

/**
 * Authenticated request after JWT validation.
 */
export interface AuthenticatedUser {
  userId: string;
  email: string;
  role: UserRole;
  tenantId: string | null;
}
