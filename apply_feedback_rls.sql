-- Enable Row Level Security
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

-- 1. Allow students to INSERT their own feedback
CREATE POLICY "Students can insert their own feedback" 
ON feedback FOR INSERT 
WITH CHECK (auth.uid() = student_id);

-- 2. Allow students to VIEW their own feedback (to prevent duplicate submission)
CREATE POLICY "Students can view their own feedback" 
ON feedback FOR SELECT 
USING (auth.uid() = student_id);

-- 3. Allow Admins to VIEW ALL feedback
CREATE POLICY "Admins can view all feedback" 
ON feedback FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.uid = auth.uid() 
    AND profiles.role = 'admin'
  )
);

-- 4. Allow Admins to DELETE feedback
CREATE POLICY "Admins can delete feedback" 
ON feedback FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.uid = auth.uid() 
    AND profiles.role = 'admin'
  )
);
