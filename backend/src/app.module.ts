import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HealthModule } from './modules/health/health.module';
import { AuthModule } from './modules/auth/auth.module';
import { ClinicModule } from './modules/clinic/clinic.module';
import { StaffModule } from './modules/staff/staff.module';
import { DoctorModule } from './modules/doctor/doctor.module';
import { PatientModule } from './modules/patient/patient.module';
import { AppointmentModule } from './modules/appointment/appointment.module';
import { MedicalRecordModule } from './modules/medical-record/medical-record.module';
import { PrescriptionModule } from './modules/prescription/prescription.module';
import { AuditModule } from './modules/audit/audit.module';

@Module({
  imports: [
    // ─── Configuration ──────────────────────────────────────────────────────
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // ─── Database ───────────────────────────────────────────────────────────
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres' as const,
        host: configService.get<string>('DB_HOST', 'localhost'),
        port: configService.get<number>('DB_PORT', 5432),
        username: configService.get<string>('DB_USERNAME', 'mediconnect'),
        password: configService.get<string>('DB_PASSWORD', 'mediconnect_dev_2026'),
        database: configService.get<string>('DB_NAME', 'mediconnect'),
        autoLoadEntities: true,
        synchronize: configService.get<string>('DB_SYNCHRONIZE', 'false') === 'true',
        logging: configService.get<string>('DB_LOGGING', 'false') === 'true',
      }),
    }),

    // ─── Feature Modules ────────────────────────────────────────────────────
    HealthModule,
    AuthModule,
    ClinicModule,
    StaffModule,
    DoctorModule,
    PatientModule,
    AppointmentModule,
    MedicalRecordModule,
    PrescriptionModule,
    AuditModule,
  ],
})
export class AppModule {}
