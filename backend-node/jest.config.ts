import type { Config } from 'jest';

const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',

  // Where to find tests
  testMatch: ['**/*.test.ts', '**/*.spec.ts'],

  // Setup file run before each test suite
  setupFiles: ['<rootDir>/src/tests/setup.ts'],

  // Coverage configuration
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.test.ts',
    '!src/**/*.spec.ts',
    '!src/tests/**',
    '!src/server.ts',   // entry-point — covered by integration tests
  ],
  coverageThreshold: {
    global: {
      lines: 5,
      branches: 1,
      functions: 5,
      statements: 5,
    },
  },
  coverageReporters: ['text', 'lcov', 'html'],

  // Path alias mapping (mirrors tsconfig paths if any are added later)
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@config/(.*)$': '<rootDir>/src/config/$1',
    '^@controllers/(.*)$': '<rootDir>/src/controllers/$1',
    '^@middleware/(.*)$': '<rootDir>/src/middleware/$1',
    '^@models/(.*)$': '<rootDir>/src/models/$1',
    '^@routes/(.*)$': '<rootDir>/src/routes/$1',
    '^@services/(.*)$': '<rootDir>/src/services/$1',
    '^@utils/(.*)$': '<rootDir>/src/utils/$1',
    '^@validators/(.*)$': '<rootDir>/src/validators/$1',
    '^@types/(.*)$': '<rootDir>/src/types/$1',
  },

  // ts-jest configuration
  transform: {
    '^.+\\.tsx?$': [
      'ts-jest',
      {
        tsconfig: {
          // Relax strict settings that cause issues in test files
          noUnusedLocals: false,
          noUnusedParameters: false,
        },
      },
    ],
  },

  // Global timeout for all tests (ms)
  testTimeout: 10_000,

  // Ignore compiled output and dependencies
  testPathIgnorePatterns: ['/node_modules/', '/dist/'],

  // Verbose output for CI
  verbose: true,
};

export default config;
