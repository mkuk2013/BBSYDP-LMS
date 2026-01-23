
-- 1. Enable RLS on feedback table
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing policies to prevent conflicts/duplicates
DROP POLICY IF EXISTS "Admins can delete feedback" ON feedback;
DROP POLICY IF EXISTS "Admins can view all feedback" ON feedback;
DROP POLICY IF EXISTS "Admins can update feedback" ON feedback;
DROP POLICY IF EXISTS "Students can insert their own feedback" ON feedback;
DROP POLICY IF EXISTS "Students can view their own feedback" ON feedback;

-- 3. Re-create Policies

-- A. ALLOW DELETE: Admins only
CREATE POLICY "Admins can delete feedback" 
ON feedback FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.uid = auth.uid() 
    AND profiles.role = 'admin'
  )
);

-- B. ALLOW SELECT: Admins see ALL, Students see OWN
CREATE POLICY "Admins can view all feedback" 
ON feedback FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.uid = auth.uid() 
    AND profiles.role = 'admin'
  )
);

CREATE POLICY "Students can view their own feedback" 
ON feedback FOR SELECT 
USING (auth.uid() = student_id);

-- C. ALLOW INSERT: Students only (for themselves)
CREATE POLICY "Students can insert their own feedback" 
ON feedback FOR INSERT 
WITH CHECK (auth.uid() = student_id);

-- D. ALLOW UPDATE: Admins (for marking as read)
CREATE POLICY "Admins can update feedback" 
ON feedback FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.uid = auth.uid() 
    AND profiles.role = 'admin'
  )
);

-- 4. Ensure is_read column exists
ALTER TABLE feedback ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT FALSE;
