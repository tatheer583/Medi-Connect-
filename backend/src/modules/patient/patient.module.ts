import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PatientController } from './patient.controller';
import { PatientService } from './patient.service';
import { PatientProfile, EmergencyContact, InsuranceInfo } from './entities';

@Module({
  imports: [TypeOrmModule.forFeature([PatientProfile, EmergencyContact, InsuranceInfo])],
  controllers: [PatientController],
  providers: [PatientService],
  exports: [PatientService],
})
export class PatientModule {}
