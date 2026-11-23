import { supabase } from '@/lib/supabase'
import type { Profile } from '@/types'

export const profilesService = {
  
  /**
  * Returns null if the profile doesn't exist or RLS doesn't let caller see it
  */
  async getProfile(userId: string): Promise<Profile | null> {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .maybeSingle()

    if (error) throw error
    return data
  },
}
