import { beforeEach, describe, expect, it } from '@jest/globals'
import { supabase } from '@/lib/supabase'
import { profilesService } from '../profilesService'
import { signInAs } from './supabaseTestClient'

// Runs against the local Supabase (`npm run db:start`) using seed.sql users
const ARTIST_1 = '11111111-1111-1111-1111-111111111111'
const ARTIST_2 = '22222222-2222-2222-2222-222222222222'

beforeEach(async () => {
  await supabase.auth.signOut()
})

describe('profilesService.getProfile', () => {
  it("returns the signed-in user's own profile", async () => {
    const user = await signInAs('artist1@example.com')
    await expect(profilesService.getProfile(user.id)).resolves.toMatchObject({
      username: 'sunny_sketches',
      role: 'artist',
    })
  })

  it("returns null for another artist's profile (RLS)", async () => {
    await signInAs('artist1@example.com')
    await expect(profilesService.getProfile(ARTIST_2)).resolves.toBeNull()
  })

  it("lets an admin read any artist's profile", async () => {
    await signInAs('admin@example.com')
    await expect(profilesService.getProfile(ARTIST_1)).resolves.toMatchObject({ username: 'sunny_sketches' })
  })

  it('throws when nobody is signed in', async () => {
    await expect(profilesService.getProfile(ARTIST_1)).rejects.toMatchObject({ code: '42501' })
  })
})
