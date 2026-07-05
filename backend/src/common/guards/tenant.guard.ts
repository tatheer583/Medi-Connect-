import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';

/**
 * Guard that enforces tenant isolation per PRD Section 5.
 * Ensures the authenticated user can only access resources within their own tenant.
 * tenant_id is ALWAYS derived from the authenticated session, never from client input.
 */
@Injectable()
export class TenantGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('Authentication required');
    }

    // SuperAdmin operates above tenants — they have cross-tenant metadata access
    if (user.role === 'super_admin') {
      return true;
    }

    // Every non-SuperAdmin must have a tenant_id
    if (!user.tenantId) {
      throw new ForbiddenException('Tenant context is required');
    }

    // If route has a clinicId param, verify it matches the user's tenant
    const clinicId = request.params.clinicId || request.params.id;
    if (clinicId && request.route?.path?.includes('clinics')) {
      if (clinicId !== user.tenantId) {
        throw new ForbiddenException('Cross-tenant access denied');
      }
    }

    // Inject tenantId into the request for downstream services
    request.tenantId = user.tenantId;

    return true;
  }
}
