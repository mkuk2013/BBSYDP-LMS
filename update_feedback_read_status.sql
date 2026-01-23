
-- Add is_read column to feedback table
ALTER TABLE feedback 
ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT FALSE;

-- Update existing records to be unread (or read if you prefer, but default false implies unread)
-- If you want all OLD feedback to be considered "read" so the counter starts at 0, run:
-- UPDATE feedback SET is_read = TRUE;
-- Otherwise, they will show as unread.

-- Policy to allow admins to update the is_read status
-- (Assuming "Admins can update feedback" policy doesn't exist or needs to be specific)
CREATE POLICY "Admins can update feedback" 
ON feedback FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.uid = auth.uid() 
    AND profiles.role = 'admin'
  )
);
