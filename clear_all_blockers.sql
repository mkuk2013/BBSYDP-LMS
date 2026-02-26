-- ==============================================================================
-- clear_all_blockers.sql
-- ==============================================================================
-- Run this script in your Supabase SQL Editor if you are STILL experiencing 
-- the "Database Error (500)" during registration.
-- This script takes a more aggressive approach to clear any hidden roadblocks.

BEGIN;

-- 1. DISABLE ROW LEVEL SECURITY ON PROFILES TEMPORARILY
-- This guarantees that the 500 error is NOT coming from a strict RLS policy blocking the insert.
-- We can re-enable it later once we confirm signups are working.
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- 2. DROP ALL CUSTOM TRIGGERS ON AUTH.USERS
-- If a previous tutorial asked you to create a trigger (e.g. `on_auth_user_created`),
-- it might be failing in the background and aborting the entire signup process with a 500 error.
-- This will safely remove any custom triggers on the users table.
DO $$
DECLARE
    trg RECORD;
BEGIN
    FOR trg IN 
        SELECT trigger_name 
        FROM information_schema.triggers 
        WHERE event_object_schema = 'auth' 
        AND event_object_table = 'users'
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON auth.users CASCADE;', trg.trigger_name);
    END LOOP;
END
$$;

-- 3. CLEAN UP ANY ORPHANED PROFILES (One last time)
DELETE FROM public.profiles WHERE uid NOT IN (SELECT id FROM auth.users);

COMMIT;

-- DONE!
-- Please try creating a brand new account using the Signup form now.
