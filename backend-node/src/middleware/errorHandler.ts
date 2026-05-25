import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';

export interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
  code?: string;
}

/**
 * Creates a structured operational error.
 */
export function createError(
  message: string,
  statusCode: number = 500,
  code?: string
): AppError {
  const error: AppError = new Error(message);
  error.statusCode = statusCode;
  error.isOperational = true;
  if (code) error.code = code;
  return error;
}

interface ErrorResponse {
  success: false;
  error: {
    message: string;
    code?: string;
    statusCode: number;
    stack?: string;
  };
}

/**
 * Global error handling middleware.
 * Must be registered AFTER all routes.
 */
export function errorHandler(
  err: AppError,
  req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _next: NextFunction
): void {
  const statusCode = err.statusCode ?? 500;
  const isProduction = process.env['NODE_ENV'] === 'production';

  // Log the error
  if (statusCode >= 500) {
    logger.error(`[${req.method}] ${req.path} - ${err.message}`, {
      statusCode,
      stack: err.stack,
      body: req.body as unknown,
    });
  } else {
    logger.warn(`[${req.method}] ${req.path} - ${err.message}`, {
      statusCode,
      code: err.code,
    });
  }

  const response: ErrorResponse = {
    success: false,
    error: {
      message: isProduction && statusCode === 500 ? 'Internal server error' : err.message,
      code: err.code,
      statusCode,
      ...(isProduction ? {} : { stack: err.stack }),
    },
  };

  res.status(statusCode).json(response);
}

/**
 * Middleware to handle 404 Not Found for unmatched routes.
 */
export function notFoundHandler(req: Request, _res: Response, next: NextFunction): void {
  const error = createError(`Route not found: ${req.method} ${req.path}`, 404, 'NOT_FOUND');
  next(error);
}
