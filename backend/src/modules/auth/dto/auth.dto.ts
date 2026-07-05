import { IsEmail, IsString, MinLength, MaxLength, IsEnum, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { UserRole } from '../../../common/enums';

export class RegisterDto {
  @ApiProperty({ example: 'doctor@clinic.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'SecurePass123!', minLength: 8 })
  @IsString()
  @MinLength(8)
  @MaxLength(128)
  password: string;

  @ApiPropertyOptional({ example: 'John' })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  firstName?: string;

  @ApiPropertyOptional({ example: 'Doe' })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  lastName?: string;

  @ApiPropertyOptional({ enum: UserRole, default: UserRole.PATIENT })
  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole;

  @ApiPropertyOptional({ description: 'Invite token for staff registration' })
  @IsOptional()
  @IsString()
  inviteToken?: string;
}

export class LoginDto {
  @ApiProperty({ example: 'doctor@clinic.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'SecurePass123!' })
  @IsString()
  password: string;
}

export class RefreshTokenDto {
  @ApiProperty()
  @IsString()
  refreshToken: string;
}

export class PasswordResetRequestDto {
  @ApiProperty({ example: 'user@clinic.com' })
  @IsEmail()
  email: string;
}

export class PasswordResetConfirmDto {
  @ApiProperty()
  @IsString()
  token: string;

  @ApiProperty({ minLength: 8 })
  @IsString()
  @MinLength(8)
  @MaxLength(128)
  newPassword: string;
}
