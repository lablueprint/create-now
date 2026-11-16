import { createClient } from '@supabase/supabase-js'
import type { Database } from '@/types/database.types'

// Stands in for '@/lib/supabase' in service tests
export const supabase = createClient<Database>(
  process.env.EXPO_PUBLIC_SUPABASE_URL!,
  process.env.EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
  { auth: { persistSession: false, autoRefreshToken: false } },
)

export async function signInAs(email: string) {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password: 'password123' })
  if (error) throw error
  return data.user
}
