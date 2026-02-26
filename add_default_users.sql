-- ==============================================================================
-- Add Default Admin and Student Accounts
-- ==============================================================================
-- Run this script in the Supabase SQL Editor.
-- It injects the accounts directly into the auth.users table 
-- and then links them to the public.profiles table.

-- Enable pgcrypto to encrypt the passwords
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  admin_uid UUID := gen_random_uuid();
  student_uid UUID := gen_random_uuid();
BEGIN

  -- ==========================================
  -- 1. Create ADMIN Account
  -- ==========================================
  INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
  ) VALUES (
    admin_uid,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'mkuk2013@gmail.com',
    crypt('Admin@123+', gen_salt('bf')),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "Admin NAVTTC"}',
    now(),
    now()
  );

  INSERT INTO public.profiles (uid, name, email, role, status, created_at)
  VALUES (
    admin_uid,
    'Admin NAVTTC',
    'mkuk2013@gmail.com',
    'admin',
    'approved',
    now()
  );


  -- ==========================================
  -- 2. Create STUDENT Account
  -- ==========================================
  INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
  ) VALUES (
    student_uid,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'demostudent@gmail.com',
    crypt('demo123', gen_salt('bf')),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "Demo Student"}',
    now(),
    now()
  );

  INSERT INTO public.profiles (uid, name, email, role, status, created_at)
  VALUES (
    student_uid,
    'Demo Student',
    'demostudent@gmail.com',
    'student',
    'approved',
    now()
  );

END
$$;
