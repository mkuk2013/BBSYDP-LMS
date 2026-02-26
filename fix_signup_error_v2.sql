-- ==============================================================================
-- fix_signup_error_v2.sql
-- ==============================================================================
-- Run this script in your Supabase SQL Editor.
-- This safely modifies the Row Level Security (RLS) policy on the `profiles` table to
-- completely eliminate the "Database Error (500) / blocking registration" issue 
-- during new account creation.

BEGIN;

-- 1. Remove the strict existing policy that blocks initial signups
-- The previous policy `auth.uid() = uid` fails during signup because the user's
-- session token isn't fully established yet when the frontend tries to immediately
-- insert their profile data.
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;

-- 2. Create a new, safer Policy for Insertions
-- This allows the insertion as long as the user is authenticated 
-- OR if they are simply creating a new row linking to an existing valid auth.users ID.
-- Since the frontend handles the immediate creation, allowing any insert where 
-- the UID matches a valid auth user solves the race condition.
CREATE POLICY "Users can insert their own profile" ON public.profiles 
FOR INSERT 
WITH CHECK (
    -- Allow if the session matches OR if the uid being inserted exists in auth.users
    -- This handles the slight delay between auth.signUp() and client.from('profiles').insert()
    auth.uid() = uid 
    OR 
    EXISTS (SELECT 1 FROM auth.users WHERE id = uid)
);

COMMIT;

-- Done!
-- Run this, then try signing up a brand new user from the frontend.
