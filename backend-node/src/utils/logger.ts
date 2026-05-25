import morgan from 'morgan';
import { Request, Response } from 'express';

type LogLevel = 'info' | 'warn' | 'error' | 'debug';

const LOG_LEVEL = process.env['LOG_LEVEL'] ?? 'info';

const levelPriority: Record<LogLevel, number> = {
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
};

function shouldLog(level: LogLevel): boolean {
  const currentPriority = levelPriority[LOG_LEVEL as LogLevel] ?? 1;
  return levelPriority[level] >= currentPriority;
}

function formatMessage(level: LogLevel, message: string, meta?: unknown): string {
  const timestamp = new Date().toISOString();
  const metaStr = meta !== undefined ? ` ${JSON.stringify(meta)}` : '';
  return `[${timestamp}] [${level.toUpperCase()}] ${message}${metaStr}`;
}

export const logger = {
  info(message: string, meta?: unknown): void {
    if (shouldLog('info')) {
      console.log(formatMessage('info', message, meta));
    }
  },

  warn(message: string, meta?: unknown): void {
    if (shouldLog('warn')) {
      console.warn(formatMessage('warn', message, meta));
    }
  },

  error(message: string, meta?: unknown): void {
    if (shouldLog('error')) {
      console.error(formatMessage('error', message, meta));
    }
  },

  debug(message: string, meta?: unknown): void {
    if (shouldLog('debug')) {
      console.debug(formatMessage('debug', message, meta));
    }
  },
};

/**
 * Morgan HTTP request logger middleware.
 * Uses 'dev' format in development, 'combined' in production.
 */
export const httpLogger = morgan(
  process.env['NODE_ENV'] === 'production' ? 'combined' : 'dev',
  {
    skip: (_req: Request, res: Response) => {
      // Skip logging for health check endpoint in production
      return process.env['NODE_ENV'] === 'production' && res.statusCode < 400;
    },
    stream: {
      write: (message: string) => {
        logger.info(message.trim());
      },
    },
  }
);
