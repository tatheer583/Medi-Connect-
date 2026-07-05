import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MedicalRecordController } from './medical-record.controller';
import { MedicalRecordService } from './medical-record.service';
import { MedicalRecordEntry } from './entities';

@Module({
  imports: [TypeOrmModule.forFeature([MedicalRecordEntry])],
  controllers: [MedicalRecordController],
  providers: [MedicalRecordService],
  exports: [MedicalRecordService],
})
export class MedicalRecordModule {}
