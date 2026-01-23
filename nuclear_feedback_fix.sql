
-- NUCLEAR OPTION: FIX FEEDBACK PERMISSIONS
-- Run this in Supabase SQL Editor

-- 1. DISABLE RLS TEMPORARILY (To confirm if RLS is the issue)
-- ALTER TABLE feedback DISABLE ROW LEVEL SECURITY;
-- (Uncomment above line if you want to test without security first)

-- 2. RE-ENABLE RLS
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

-- 3. DROP ALL EXISTING POLICIES (Clean Slate)
DROP POLICY IF EXISTS "Admins can delete feedback" ON feedback;
DROP POLICY IF EXISTS "Admins can view all feedback" ON feedback;
DROP POLICY IF EXISTS "Admins can update feedback" ON feedback;
DROP POLICY IF EXISTS "Students can insert their own feedback" ON feedback;
DROP POLICY IF EXISTS "Students can view their own feedback" ON feedback;
DROP POLICY IF EXISTS "Admins can do everything" ON feedback;
DROP POLICY IF EXISTS "Students Insert" ON feedback;
DROP POLICY IF EXISTS "Students View" ON feedback;

-- 4. CREATE SIMPLIFIED POLICIES

-- Policy A: Students can INSERT their own feedback
CREATE POLICY "Students Insert" 
ON feedback FOR INSERT 
WITH CHECK (auth.uid() = student_id);

-- Policy B: Students can VIEW their own feedback
CREATE POLICY "Students View" 
ON feedback FOR SELECT 
USING (auth.uid() = student_id);

-- Policy C: ADMIN MASTER POLICY (using raw_user_meta_data if profiles fails, or fallback)
-- We check profiles table OR if the user metadata claims admin (if you use that)
-- For now, stick to PROFILES as it is the project standard.

CREATE POLICY "Admins Master" 
ON feedback 
FOR ALL 
USING (
  (SELECT role FROM profiles WHERE uid = auth.uid()) = 'admin'
);

-- 5. VERIFY PROFILES
-- Ensure your user actually has 'admin' role in the profiles table.
-- You can run: SELECT * FROM profiles WHERE uid = auth.uid();
