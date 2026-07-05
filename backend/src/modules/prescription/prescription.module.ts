import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PrescriptionController } from './prescription.controller';
import { PrescriptionService } from './prescription.service';
import { Prescription, PrescriptionItem } from './entities';

@Module({
  imports: [TypeOrmModule.forFeature([Prescription, PrescriptionItem])],
  controllers: [PrescriptionController],
  providers: [PrescriptionService],
  exports: [PrescriptionService],
})
export class PrescriptionModule {}
