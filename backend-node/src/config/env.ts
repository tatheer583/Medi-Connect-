import dotenv from 'dotenv';
import path from 'path';

// Load .env file from project root
dotenv.config({ path: path.resolve(process.cwd(), '.env') });

function requireEnv(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
}

function optionalEnv(key: string, defaultValue: string): string {
  return process.env[key] ?? defaultValue;
}

export const env = {
  // Server
  NODE_ENV: optionalEnv('NODE_ENV', 'development'),
  PORT: parseInt(optionalEnv('PORT', '5000'), 10),

  // Appwrite
  APPWRITE_ENDPOINT: optionalEnv('APPWRITE_ENDPOINT', 'https://cloud.appwrite.io/v1'),
  APPWRITE_PROJECT_ID: requireEnv('APPWRITE_PROJECT_ID'),
  APPWRITE_API_KEY: requireEnv('APPWRITE_API_KEY'),
  APPWRITE_DATABASE_ID: optionalEnv('APPWRITE_DATABASE_ID', 'mediconnect'),

  // JWT
  JWT_SECRET: requireEnv('JWT_SECRET'),
  JWT_EXPIRES_IN: optionalEnv('JWT_EXPIRES_IN', '7d'),
  JWT_REFRESH_SECRET: requireEnv('JWT_REFRESH_SECRET'),
  JWT_REFRESH_EXPIRES_IN: optionalEnv('JWT_REFRESH_EXPIRES_IN', '30d'),

  // Claude AI
  CLAUDE_API_KEY: optionalEnv('CLAUDE_API_KEY', ''),
  CLAUDE_MODEL: optionalEnv('CLAUDE_MODEL', 'claude-3-haiku-20240307'),

  // Redis
  REDIS_URL: optionalEnv('REDIS_URL', 'redis://localhost:6379'),

  // Twilio (SMS/Email)
  TWILIO_ACCOUNT_SID: optionalEnv('TWILIO_ACCOUNT_SID', ''),
  TWILIO_AUTH_TOKEN: optionalEnv('TWILIO_AUTH_TOKEN', ''),
  TWILIO_PHONE_NUMBER: optionalEnv('TWILIO_PHONE_NUMBER', ''),

  // CORS
  CORS_ORIGIN: optionalEnv('CORS_ORIGIN', 'http://localhost:3000'),

  // Logging
  LOG_LEVEL: optionalEnv('LOG_LEVEL', 'info'),
} as const;

export type Env = typeof env;
