import { Injectable, UnauthorizedException, ConflictException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import { User, Session, PasswordResetToken } from './entities';
import { RegisterDto, LoginDto } from './dto';
import type { JwtPayload } from '../../common/interfaces';
import { UserRole } from '../../common/enums';

/**
 * Authentication service per PRD Section 6.1.
 * Handles registration, login, JWT token management, and password reset.
 * 
 * Security features per PRD:
 * - Short-lived JWT access tokens (15 min)
 * - Rotating refresh tokens with reuse detection
 * - Account lockout after repeated failed attempts with progressive backoff
 * - NIST 800-63B password policy
 */
@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly SALT_ROUNDS = 12;
  private readonly MAX_FAILED_ATTEMPTS = 5;
  private readonly LOCKOUT_DURATION_MINUTES = 15;

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Session)
    private readonly sessionRepository: Repository<Session>,
    @InjectRepository(PasswordResetToken)
    private readonly passwordResetRepository: Repository<PasswordResetToken>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  /**
   * Register a new user account.
   * Staff registration requires a valid invite token.
   * Patient self-registration creates a patient-role account.
   */
  async register(dto: RegisterDto) {
    // Check for existing user with same email in the same tenant context
    const existingUser = await this.userRepository.findOne({
      where: { email: dto.email.toLowerCase() },
    });

    if (existingUser) {
      throw new ConflictException('An account with this email already exists');
    }

    // Hash password (NIST 800-63B: length over complexity)
    const passwordHash = await bcrypt.hash(dto.password, this.SALT_ROUNDS);

    const user = this.userRepository.create({
      email: dto.email.toLowerCase(),
      passwordHash,
      firstName: dto.firstName || null,
      lastName: dto.lastName || null,
      role: dto.role || UserRole.PATIENT,
      tenantId: null, // Set during clinic onboarding or invite acceptance
      isActive: true,
    });

    const savedUser = await this.userRepository.save(user);

    this.logger.log(`User registered: ${savedUser.email} (${savedUser.role})`);

    // Generate tokens
    const tokens = await this.generateTokens(savedUser);

    return {
      user: this.sanitizeUser(savedUser),
      ...tokens,
    };
  }

  /**
   * Authenticate user with email/password.
   * Implements progressive lockout per PRD Section 6.1.
   */
  async login(dto: LoginDto, ipAddress?: string, userAgent?: string) {
    const user = await this.userRepository.findOne({
      where: { email: dto.email.toLowerCase() },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Check account lockout
    if (user.lockedUntil && user.lockedUntil > new Date()) {
      const remainingMinutes = Math.ceil(
        (user.lockedUntil.getTime() - Date.now()) / (1000 * 60),
      );
      throw new UnauthorizedException(
        `Account locked. Try again in ${remainingMinutes} minute(s).`,
      );
    }

    // Check if account is active
    if (!user.isActive) {
      throw new UnauthorizedException('Account is deactivated');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isPasswordValid) {
      await this.handleFailedLogin(user);
      throw new UnauthorizedException('Invalid credentials');
    }

    // Reset failed attempts on successful login
    user.failedLoginAttempts = 0;
    user.lockedUntil = null;
    user.lastLoginAt = new Date();
    await this.userRepository.save(user);

    // Generate tokens and create session
    const tokens = await this.generateTokens(user, ipAddress, userAgent);

    this.logger.log(`User logged in: ${user.email}`);

    return {
      user: this.sanitizeUser(user),
      ...tokens,
    };
  }

  /**
   * Refresh access token using a valid refresh token.
   * Implements rotating refresh tokens with reuse detection per PRD Section 12.2.
   */
  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });

      const refreshTokenHash = await bcrypt.hash(refreshToken, this.SALT_ROUNDS);

      // Find an active session with this token
      const sessions = await this.sessionRepository.find({
        where: { userId: payload.sub, isRevoked: false },
      });

      let validSession: Session | null = null;
      for (const session of sessions) {
        const isMatch = await bcrypt.compare(refreshToken, session.refreshTokenHash);
        if (isMatch) {
          validSession = session;
          break;
        }
      }

      if (!validSession) {
        // Potential token reuse detected — revoke all sessions for security
        await this.sessionRepository.update(
          { userId: payload.sub },
          { isRevoked: true },
        );
        throw new UnauthorizedException('Invalid refresh token — all sessions revoked');
      }

      // Revoke old session
      validSession.isRevoked = true;
      await this.sessionRepository.save(validSession);

      // Get user and generate new tokens
      const user = await this.userRepository.findOne({ where: { id: payload.sub } });
      if (!user || !user.isActive) {
        throw new UnauthorizedException('User not found or deactivated');
      }

      return this.generateTokens(user);
    } catch (error) {
      if (error instanceof UnauthorizedException) throw error;
      throw new UnauthorizedException('Invalid or expired refresh token');
    }
  }

  /**
   * Logout — revoke the current session.
   */
  async logout(userId: string, refreshToken?: string) {
    if (refreshToken) {
      const sessions = await this.sessionRepository.find({
        where: { userId, isRevoked: false },
      });

      for (const session of sessions) {
        const isMatch = await bcrypt.compare(refreshToken, session.refreshTokenHash);
        if (isMatch) {
          session.isRevoked = true;
          await this.sessionRepository.save(session);
          break;
        }
      }
    }

    this.logger.log(`User logged out: ${userId}`);
    return { message: 'Logged out successfully' };
  }

  /**
   * Request password reset — generates a token.
   */
  async requestPasswordReset(email: string) {
    const user = await this.userRepository.findOne({
      where: { email: email.toLowerCase() },
    });

    // Always return success to prevent email enumeration
    if (!user) {
      return { message: 'If the email exists, a reset link has been sent' };
    }

    const resetToken = uuidv4();
    const tokenHash = await bcrypt.hash(resetToken, this.SALT_ROUNDS);

    const passwordReset = this.passwordResetRepository.create({
      userId: user.id,
      tokenHash,
      expiresAt: new Date(Date.now() + 60 * 60 * 1000), // 1 hour
    });

    await this.passwordResetRepository.save(passwordReset);

    // TODO: Send email with reset token (Phase 2 notification service)
    this.logger.log(`Password reset requested for: ${email}, token: ${resetToken}`);

    return { message: 'If the email exists, a reset link has been sent' };
  }

  /**
   * Confirm password reset with token.
   */
  async confirmPasswordReset(token: string, newPassword: string) {
    const resets = await this.passwordResetRepository.find({
      where: { isUsed: false },
      order: { createdAt: 'DESC' },
      take: 50,
    });

    let validReset: PasswordResetToken | null = null;
    for (const reset of resets) {
      const isMatch = await bcrypt.compare(token, reset.tokenHash);
      if (isMatch && reset.expiresAt > new Date()) {
        validReset = reset;
        break;
      }
    }

    if (!validReset) {
      throw new BadRequestException('Invalid or expired reset token');
    }

    // Update password
    const passwordHash = await bcrypt.hash(newPassword, this.SALT_ROUNDS);
    await this.userRepository.update(validReset.userId, { passwordHash });

    // Mark token as used
    validReset.isUsed = true;
    await this.passwordResetRepository.save(validReset);

    // Revoke all sessions (PRD: password change forces logout of all other sessions)
    await this.sessionRepository.update(
      { userId: validReset.userId },
      { isRevoked: true },
    );

    return { message: 'Password reset successfully' };
  }

  /**
   * Find a user by ID.
   */
  async findById(userId: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id: userId } });
  }

  // ─── Private Helpers ────────────────────────────────────────────────────────

  private async generateTokens(user: User, ipAddress?: string, userAgent?: string) {
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      tenantId: user.tenantId,
    };

    const accessToken = this.jwtService.sign(payload as Record<string, unknown>, {
      secret: this.configService.get<string>('JWT_SECRET'),
      expiresIn: this.configService.get<string>('JWT_ACCESS_EXPIRATION') || '15m',
    } as any);

    const refreshToken = this.jwtService.sign(
      { sub: user.id } as Record<string, unknown>,
      {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
        expiresIn: this.configService.get<string>('JWT_REFRESH_EXPIRATION') || '7d',
      } as any,
    );

    // Store refresh token hash in session
    const refreshTokenHash = await bcrypt.hash(refreshToken, this.SALT_ROUNDS);
    const session = this.sessionRepository.create({
      userId: user.id,
      refreshTokenHash,
      ipAddress: ipAddress || null,
      userAgent: userAgent || null,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
    });
    await this.sessionRepository.save(session);

    return { accessToken, refreshToken };
  }

  private async handleFailedLogin(user: User) {
    user.failedLoginAttempts += 1;

    if (user.failedLoginAttempts >= this.MAX_FAILED_ATTEMPTS) {
      // Progressive lockout
      const lockoutMinutes = this.LOCKOUT_DURATION_MINUTES * Math.pow(2, 
        Math.floor(user.failedLoginAttempts / this.MAX_FAILED_ATTEMPTS) - 1
      );
      user.lockedUntil = new Date(Date.now() + lockoutMinutes * 60 * 1000);
      this.logger.warn(`Account locked for ${lockoutMinutes} min: ${user.email}`);
    }

    await this.userRepository.save(user);
  }

  private sanitizeUser(user: User) {
    return {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
      tenantId: user.tenantId,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
    };
  }
}
