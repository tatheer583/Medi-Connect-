import {
  Controller,
  Post,
  Body,
  Req,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto, LoginDto, RefreshTokenDto, PasswordResetRequestDto, PasswordResetConfirmDto } from './dto';
import { CurrentUser } from '../../common/decorators';
import type { AuthenticatedUser } from '../../common/interfaces';
import type { Request } from 'express';

/**
 * Authentication controller per PRD Section 10.2.
 * Endpoints: register, login, refresh, logout, password reset.
 */
@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Create a new account (role-gated by invite context)' })
  @ApiResponse({ status: 201, description: 'Account created successfully' })
  @ApiResponse({ status: 409, description: 'Email already exists' })
  async register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Authenticate and receive JWT tokens' })
  @ApiResponse({ status: 200, description: 'Login successful' })
  @ApiResponse({ status: 401, description: 'Invalid credentials or account locked' })
  async login(@Body() dto: LoginDto, @Req() req: Request) {
    const ipAddress = req.ip || req.socket.remoteAddress;
    const userAgent = req.headers['user-agent'];
    return this.authService.login(dto, ipAddress, userAgent);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Exchange refresh token for new access token' })
  @ApiResponse({ status: 200, description: 'Tokens refreshed' })
  @ApiResponse({ status: 401, description: 'Invalid or expired refresh token' })
  async refreshToken(@Body() dto: RefreshTokenDto) {
    return this.authService.refreshToken(dto.refreshToken);
  }

  @Post('logout')
  @UseGuards(AuthGuard('jwt'))
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Revoke current session' })
  @ApiResponse({ status: 200, description: 'Logged out successfully' })
  async logout(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: { refreshToken?: string },
  ) {
    return this.authService.logout(user.userId, body.refreshToken);
  }

  @Post('password/reset-request')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Begin password reset flow' })
  @ApiResponse({ status: 200, description: 'Reset email sent (if account exists)' })
  async requestPasswordReset(@Body() dto: PasswordResetRequestDto) {
    return this.authService.requestPasswordReset(dto.email);
  }

  @Post('password/reset-confirm')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Complete password reset with token' })
  @ApiResponse({ status: 200, description: 'Password reset successfully' })
  @ApiResponse({ status: 400, description: 'Invalid or expired token' })
  async confirmPasswordReset(@Body() dto: PasswordResetConfirmDto) {
    return this.authService.confirmPasswordReset(dto.token, dto.newPassword);
  }
}
