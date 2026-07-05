import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DoctorController } from './doctor.controller';
import { DoctorService } from './doctor.service';
import { DoctorProfile, PatientDoctorAssignment, AccessGrant } from './entities';

@Module({
  imports: [TypeOrmModule.forFeature([DoctorProfile, PatientDoctorAssignment, AccessGrant])],
  controllers: [DoctorController],
  providers: [DoctorService],
  exports: [DoctorService],
})
export class DoctorModule {}
