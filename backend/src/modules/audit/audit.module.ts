import { Module, Global } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuditController } from './audit.controller';
import { AuditService } from './audit.service';
import { AuditLogEntry } from './entities';

@Global() // Global so any module can inject AuditService for logging
@Module({
  imports: [TypeOrmModule.forFeature([AuditLogEntry])],
  controllers: [AuditController],
  providers: [AuditService],
  exports: [AuditService],
})
export class AuditModule {}
