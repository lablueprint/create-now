const moduleNameMapper = { '^@/(.*)$': '<rootDir>/src/$1' }

/** @type {import('jest').Config} */
module.exports = {
  projects: [
    {
      // Node environment: services that talk to the local Supabase.
      preset: 'jest-expo/node',
      displayName: 'services',
      moduleNameMapper: {
        '^@/lib/supabase$': '<rootDir>/src/services/tests/supabaseTestClient.ts',
        ...moduleNameMapper,
      },
      setupFiles: ['<rootDir>/jest.setup.ts'],
      testMatch: ['<rootDir>/src/services/**/*.test.ts'],
    },
    {
      // React Native environment: screens and components.
      preset: 'jest-expo/ios',
      displayName: 'app',
      moduleNameMapper,
      testPathIgnorePatterns: ['/node_modules/', '<rootDir>/src/services/'],
    },
  ],
}
