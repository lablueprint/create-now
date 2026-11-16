/// <reference types="node" />
import { existsSync, readFileSync } from 'node:fs'
import { parseEnv } from 'node:util'

// Loads .env.local / .env for tests (CI sets the variables itself). Existing values win.
for (const file of ['.env.local', '.env']) {
  if (!existsSync(file)) continue
  for (const [key, value] of Object.entries(parseEnv(readFileSync(file, 'utf8')))) {
    process.env[key] ??= value
  }
}
