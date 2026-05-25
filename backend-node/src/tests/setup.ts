/**
 * Global test setup — runs before every test file.
 *
 * Sets safe placeholder environment variables so modules that call
 * requireEnv() at import time don't throw during unit tests.
 * Real integration tests should override these with actual values.
 */

// ─── Server ───────────────────────────────────────────────────────────────────
process.env['NODE_ENV'] = 'test';
process.env['PORT'] = '5001';

// ─── Appwrite ─────────────────────────────────────────────────────────────────
process.env['APPWRITE_ENDPOINT'] = 'https://cloud.appwrite.io/v1';
process.env['APPWRITE_PROJECT_ID'] = 'test_project_id';
process.env['APPWRITE_API_KEY'] = 'test_api_key';
process.env['APPWRITE_DATABASE_ID'] = 'mediconnect_test';

// ─── JWT ──────────────────────────────────────────────────────────────────────
process.env['JWT_SECRET'] = 'test_jwt_secret_at_least_32_characters_long';
process.env['JWT_EXPIRES_IN'] = '1h';
process.env['JWT_REFRESH_SECRET'] = 'test_refresh_secret_at_least_32_chars_long';
process.env['JWT_REFRESH_EXPIRES_IN'] = '7d';

// ─── Redis ────────────────────────────────────────────────────────────────────
process.env['REDIS_URL'] = 'redis://localhost:6379';

// ─── Claude AI ────────────────────────────────────────────────────────────────
process.env['CLAUDE_API_KEY'] = 'test_claude_api_key';
process.env['CLAUDE_MODEL'] = 'claude-3-haiku-20240307';

// ─── Twilio ───────────────────────────────────────────────────────────────────
process.env['TWILIO_ACCOUNT_SID'] = 'test_twilio_sid';
process.env['TWILIO_AUTH_TOKEN'] = 'test_twilio_token';
process.env['TWILIO_PHONE_NUMBER'] = '+10000000000';

// ─── CORS ─────────────────────────────────────────────────────────────────────
process.env['CORS_ORIGIN'] = 'http://localhost:3000';

// ─── Logging ──────────────────────────────────────────────────────────────────
process.env['LOG_LEVEL'] = 'error'; // suppress logs during tests

// ─── Global test timeout ──────────────────────────────────────────────────────
// jest global is available in test files; use the env variable approach here
// to avoid needing @jest/globals in the setup file.
// Timeout is set via jest.config.ts (testTimeout) instead.
