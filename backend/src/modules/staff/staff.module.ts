import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StaffController } from './staff.controller';
import { StaffService } from './staff.service';
import { StaffMember, StaffInvite } from './entities';

@Module({
  imports: [TypeOrmModule.forFeature([StaffMember, StaffInvite])],
  controllers: [StaffController],
  providers: [StaffService],
  exports: [StaffService],
})
export class StaffModule {}
