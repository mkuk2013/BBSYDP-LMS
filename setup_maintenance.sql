-- ==============================================================================
-- Add Maintenance Mode to Exam Settings
-- ==============================================================================
-- Run this in your Supabase SQL Editor.

-- 1. Add column if it doesn't exist
ALTER TABLE public.exam_settings 
ADD COLUMN IF NOT EXISTS maintenance_mode BOOLEAN DEFAULT false;

-- 2. Initialize it
UPDATE public.exam_settings SET maintenance_mode = false WHERE id = 1;

-- 3. Verify it
SELECT * FROM public.exam_settings WHERE id = 1;
