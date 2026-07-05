import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log', 'debug', 'verbose'],
  });

  const logger = new Logger('Bootstrap');

  // ─── Security ───────────────────────────────────────────────────────────────
  app.use(helmet());

  // ─── CORS ───────────────────────────────────────────────────────────────────
  app.enableCors({
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  // ─── Global Prefix ─────────────────────────────────────────────────────────
  app.setGlobalPrefix('api/v1');

  // ─── Validation ─────────────────────────────────────────────────────────────
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // ─── Swagger API Documentation ──────────────────────────────────────────────
  const config = new DocumentBuilder()
    .setTitle('MediConnect API')
    .setDescription(
      'Cloud-native, multi-tenant healthcare operations platform API. ' +
        'Unifies clinical, administrative, and AI-assisted workflows.',
    )
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'Authorization',
        description: 'Enter JWT access token',
        in: 'header',
      },
      'access-token',
    )
    .addTag('Auth', 'Authentication & Access Control')
    .addTag('Clinics', 'Clinic & Branch Management')
    .addTag('Staff', 'Staff Management')
    .addTag('Doctors', 'Doctor Portal & Management')
    .addTag('Patients', 'Patient Management & Portal')
    .addTag('Appointments', 'Appointment Scheduling')
    .addTag('Medical Records', 'Electronic Medical Records')
    .addTag('Prescriptions', 'Prescription Management')
    .addTag('Audit', 'Audit Logs & Compliance')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  // ─── Start ──────────────────────────────────────────────────────────────────
  const port = process.env.PORT || 5000;
  await app.listen(port);

  logger.log(`🚀 MediConnect API running on http://localhost:${port}`);
  logger.log(`📚 Swagger docs at http://localhost:${port}/api/docs`);
  logger.log(`❤️  Health check at http://localhost:${port}/api/v1/health`);
}

bootstrap();
