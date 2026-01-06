-- =================================================================================
-- SUPABASE ADMIN DELETION FUNCTION
-- =================================================================================
-- Run this entire script in your Supabase Dashboard > SQL Editor.
-- This creates a secure function that allows the Admin Dashboard to permanently delete
-- users from both the Database (profiles) AND the Authentication system (email login).
-- =================================================================================

CREATE OR REPLACE FUNCTION delete_user_via_admin(target_uid uuid)
RETURNS void AS $$
BEGIN
  -- 1. Delete the user from the Authentication table
  -- This frees up the email so it can be registered again.
  DELETE FROM auth.users WHERE id = target_uid;
  
  -- 2. Delete the user profile from the Public table
  -- (Note: If ON DELETE CASCADE is set up, this might happen automatically, but we force it to be sure)
  DELETE FROM public.profiles WHERE uid = target_uid;
  
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =================================================================================
-- DONE. Now try deleting the user from the Admin Dashboard again.
-- =================================================================================
