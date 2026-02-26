-- ==============================================================================
-- fix_auth_users.sql
-- ==============================================================================
-- Run this script in your Supabase SQL Editor.
-- This fixes the "Database error querying schema" that occurs during login 
-- when accounts are added manually via SQL. 

BEGIN;

-- Supabase Auth (GoTrue) strictly expects certain token columns to be empty strings ('') 
-- rather than NULL. Our previous manual insertion left them as NULL, causing the login crash.
-- This safely updates any affected users.

UPDATE auth.users 
SET 
  confirmation_token = COALESCE(confirmation_token, ''),
  recovery_token = COALESCE(recovery_token, ''),
  email_change_token_new = COALESCE(email_change_token_new, ''),
  email_change = COALESCE(email_change, '')
WHERE 
  confirmation_token IS NULL OR 
  recovery_token IS NULL OR 
  email_change_token_new IS NULL OR 
  email_change IS NULL;

-- Also ensure these boolean flags aren't null (some older Supabase versions need them)
UPDATE auth.users
SET 
  is_super_admin = COALESCE(is_super_admin, false),
  is_sso_user = COALESCE(is_sso_user, false)
WHERE 
  is_super_admin IS NULL OR 
  is_sso_user IS NULL;

COMMIT;

-- Done!
-- Please try logging in with the Demo Student or Admin account now.
