import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ClinicController } from './clinic.controller';
import { ClinicService } from './clinic.service';
import { Clinic, Branch, Department } from './entities';

@Module({
  imports: [TypeOrmModule.forFeature([Clinic, Branch, Department])],
  controllers: [ClinicController],
  providers: [ClinicService],
  exports: [ClinicService],
})
export class ClinicModule {}
