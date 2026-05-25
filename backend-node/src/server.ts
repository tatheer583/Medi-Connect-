import dotenv from 'dotenv';
import path from 'path';

// Load environment variables before importing anything else
dotenv.config({ path: path.resolve(process.cwd(), '.env') });

import app from './app';
import { logger } from './utils/logger';

const PORT = parseInt(process.env['PORT'] ?? '5000', 10);
const NODE_ENV = process.env['NODE_ENV'] ?? 'development';

const server = app.listen(PORT, () => {
  logger.info(`MediConnectSmart API server started`, {
    port: PORT,
    environment: NODE_ENV,
    url: `http://localhost:${PORT}`,
    health: `http://localhost:${PORT}/health`,
  });
});

// ─── Graceful Shutdown ────────────────────────────────────────────────────────
function gracefulShutdown(signal: string): void {
  logger.info(`Received ${signal}. Starting graceful shutdown...`);

  server.close((err) => {
    if (err) {
      logger.error('Error during server shutdown', err);
      process.exit(1);
    }
    logger.info('Server closed successfully');
    process.exit(0);
  });

  // Force shutdown after 10 seconds
  setTimeout(() => {
    logger.error('Forced shutdown after timeout');
    process.exit(1);
  }, 10_000);
}

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// ─── Unhandled Rejections & Exceptions ───────────────────────────────────────
process.on('unhandledRejection', (reason: unknown) => {
  logger.error('Unhandled Promise Rejection', reason);
  gracefulShutdown('unhandledRejection');
});

process.on('uncaughtException', (error: Error) => {
  logger.error('Uncaught Exception', error);
  gracefulShutdown('uncaughtException');
});

export default server;
