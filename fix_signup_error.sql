-- ==========================================================
-- ADVANCED FIX FOR SIGNUP 500 ERROR
-- ==========================================================
-- This script does 3 things:
-- 1. Cleans up "Ghost" profiles (Orphans).
-- 2. Creates a ROBUST Trigger function (Safe against crashes).
-- 3. Re-attaches the Trigger to the Auth system.
-- ==========================================================

-- 1. AGGRESSIVE CLEANUP
DELETE FROM public.profiles WHERE uid NOT IN (SELECT id FROM auth.users);
-- Also clean by email to be safe (orphaned emails)
DELETE FROM public.profiles 
WHERE email NOT IN (SELECT email FROM auth.users);

-- 2. CREATE A SAFE TRIGGER FUNCTION
-- This function uses "ON CONFLICT DO NOTHING" to prevent crashes 
-- if the profile already exists. It also handles missing names safely.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (uid, name, email, role, status)
  VALUES (
    new.id, 
    COALESCE(new.raw_user_meta_data->>'name', 'New User'), 
    new.email,
    'student', 
    'pending'
  )
  ON CONFLICT (uid) DO NOTHING; -- CRITICAL: Prevents 500 Error
  RETURN new;
END;
$$;

-- 3. RESET THE TRIGGER
-- We drop the common trigger name and re-create it to use our Safe Function.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==========================================================
-- DONE. The 500 Error should be permanently gone.
-- ==========================================================
