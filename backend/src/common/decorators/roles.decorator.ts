import { SetMetadata } from '@nestjs/common';
import { UserRole } from '../enums';

export const ROLES_KEY = 'roles';

/**
 * Decorator to restrict endpoint access to specific roles.
 * Per PRD Section 4.2 Permission Matrix.
 * Usage: @Roles(UserRole.DOCTOR, UserRole.CLINIC_ADMIN)
 */
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);
