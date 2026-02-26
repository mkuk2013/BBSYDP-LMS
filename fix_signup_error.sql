-- ==============================================================================
-- fix_signup_error.sql
-- ==============================================================================
-- Run this script in your Supabase SQL Editor if you are experiencing
-- "Database Error (500). An old Profile is likely blocking registration."

-- 1. DELETE ORPHANED PROFILES
-- This safely removes any profiles from 'public.profiles' that no longer
-- have a matching user account in the 'auth.users' table.
-- This usually happens if a user was deleted from the dashboard before 
-- the 'ON DELETE CASCADE' rule was fully implemented.
DELETE FROM public.profiles
WHERE uid NOT IN (SELECT id FROM auth.users);

-- 2. FIX DUPLICATE EMAILS (Failsafe)
-- If a profile exists with an email but no longer matches an active auth user,
-- it will block new signups using that email. The above query handles most of this,
-- but this ensures complete cleanup of dead email records.
DELETE FROM public.profiles 
WHERE email NOT IN (SELECT email FROM auth.users WHERE email IS NOT NULL);

-- 3. REMOVE CONFLICTING TRIGGERS (Optional Safety Measure)
-- If you followed a tutorial earlier that instructed you to create an 
-- automatic profile-creation trigger (e.g., 'on_auth_user_created'), 
-- it can conflict with our LMS's manual profile insertion logic, causing a 500 Error.
-- The code below removes any such triggers safely.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- 4. RE-APPLY THE CASCADE RULE JUST IN CASE
-- Ensures future deletions completely destroy all user data automatically.
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_uid_fkey;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_uid_fkey 
  FOREIGN KEY (uid) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Done!
-- Once you run this script, the 500 error will disappear and new users can sign up normally.
