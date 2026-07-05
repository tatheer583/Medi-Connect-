import { IsString, MaxLength, IsOptional, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ClinicStatus } from '../../../common/enums';

export class CreateClinicDto {
  @ApiProperty({ example: 'Downtown Medical Center' })
  @IsString()
  @MaxLength(255)
  name: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ default: 'UTC' })
  @IsOptional()
  @IsString()
  timezone?: string;

  @ApiPropertyOptional({ default: 'en' })
  @IsOptional()
  @IsString()
  locale?: string;

  @ApiPropertyOptional({ default: 'USD' })
  @IsOptional()
  @IsString()
  currency?: string;
}

export class UpdateClinicDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(255)
  name?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  timezone?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  locale?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  currency?: string;

  @ApiPropertyOptional({ enum: ClinicStatus })
  @IsOptional()
  @IsEnum(ClinicStatus)
  status?: ClinicStatus;
}

export class CreateBranchDto {
  @ApiProperty({ example: 'Main Branch' })
  @IsString()
  @MaxLength(255)
  name: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  address?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  state?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  postalCode?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  country?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ default: 'UTC' })
  @IsOptional()
  @IsString()
  timezone?: string;
}

export class CreateDepartmentDto {
  @ApiProperty({ example: 'Cardiology' })
  @IsString()
  @MaxLength(255)
  name: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;
}
