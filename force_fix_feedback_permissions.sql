
-- COMPLETE PERMISSION FIX FOR FEEDBACK
-- Run this in Supabase SQL Editor

-- 1. Ensure RLS is on
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

-- 2. Drop ALL existing policies for feedback to start clean
DROP POLICY IF EXISTS "Admins can delete feedback" ON feedback;
DROP POLICY IF EXISTS "Admins can view all feedback" ON feedback;
DROP POLICY IF EXISTS "Admins can update feedback" ON feedback;
DROP POLICY IF EXISTS "Students can insert their own feedback" ON feedback;
DROP POLICY IF EXISTS "Students can view their own feedback" ON feedback;
DROP POLICY IF EXISTS "Admins can do everything" ON feedback;

-- 3. Create a MASTER Admin policy (simplifies things)
-- Allows Admins to SELECT, INSERT, UPDATE, DELETE
CREATE POLICY "Admins can do everything" 
ON feedback 
FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.uid = auth.uid() 
    AND profiles.role = 'admin'
  )
);

-- 4. Create Student Policies
CREATE POLICY "Students can view their own feedback" 
ON feedback FOR SELECT 
USING (auth.uid() = student_id);

CREATE POLICY "Students can insert their own feedback" 
ON feedback FOR INSERT 
WITH CHECK (auth.uid() = student_id);

-- 5. Fix is_read column just in case
ALTER TABLE feedback ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT FALSE;

-- 6. Optional: Mark all current feedback as READ to reset the counter to 0
-- Uncomment the next line if you want to clear current notifications:
-- UPDATE feedback SET is_read = TRUE;
