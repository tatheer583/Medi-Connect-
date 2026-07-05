import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import type { JwtPayload } from '../../../common/interfaces';
import { AuthService } from '../auth.service';

/**
 * JWT Strategy per PRD Section 5.2.
 * Extracts tenant_id, role, and user_id from verified JWT claims.
 */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(
    private readonly configService: ConfigService,
    private readonly authService: AuthService,
  ) {
    const secret = configService.get<string>('JWT_SECRET') || 'fallback-dev-secret';
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: secret,
    });
  }

  async validate(payload: any) {
    const user = await this.authService.findById(payload.sub);

    if (!user || !user.isActive) {
      throw new UnauthorizedException('Invalid or inactive user');
    }

    if (user.lockedUntil && user.lockedUntil > new Date()) {
      throw new UnauthorizedException('Account is locked');
    }

    return {
      userId: payload.sub,
      email: payload.email,
      role: payload.role,
      tenantId: payload.tenantId,
    };
  }
}
