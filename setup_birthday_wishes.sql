-- ==============================================================================
-- Birthday wishes Table & RLS Policies Setup
-- ==============================================================================

-- 1. Create table
CREATE TABLE IF NOT EXISTS public.birthday_wishes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES public.profiles(uid) ON DELETE CASCADE,
    student_name TEXT,
    wish_message TEXT NOT NULL,
    admin_name TEXT,
    replied BOOLEAN DEFAULT false,
    admin_reply TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add columns if they don't exist
ALTER TABLE public.birthday_wishes ADD COLUMN IF NOT EXISTS wish_message TEXT;
ALTER TABLE public.birthday_wishes ADD COLUMN IF NOT EXISTS admin_reply TEXT;

-- Update null wish_message with default value
UPDATE public.birthday_wishes SET wish_message = 'Happy Birthday! Wishing you continued success and leadership in our learning journey.' WHERE wish_message IS NULL;

-- Set NOT NULL constraint
ALTER TABLE public.birthday_wishes ALTER COLUMN wish_message SET NOT NULL;

-- 2. Enable RLS
ALTER TABLE public.birthday_wishes ENABLE ROW LEVEL SECURITY;

-- 3. Define Policies

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins can view all wishes" ON public.birthday_wishes;
DROP POLICY IF EXISTS "Admins can update wishes" ON public.birthday_wishes;
DROP POLICY IF EXISTS "Students can update own wishes" ON public.birthday_wishes;
DROP POLICY IF EXISTS "Students can view own wishes" ON public.birthday_wishes;
DROP POLICY IF EXISTS "Students can insert own wishes" ON public.birthday_wishes;

-- Admins can view all wishes
CREATE POLICY "Admins can view all wishes" 
ON public.birthday_wishes FOR SELECT 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- Admins can update all wishes (for replied status)
CREATE POLICY "Admins can update wishes" 
ON public.birthday_wishes FOR UPDATE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- Students can update their own wishes (for automated reply)
CREATE POLICY "Students can update own wishes" 
ON public.birthday_wishes FOR UPDATE 
USING (auth.uid() = student_id);

-- Students can view their own wishes
CREATE POLICY "Students can view own wishes" 
ON public.birthday_wishes FOR SELECT 
USING (auth.uid() = student_id);

-- Students can insert their own wishes
CREATE POLICY "Students can insert own wishes" 
ON public.birthday_wishes FOR INSERT 
WITH CHECK (auth.uid() = student_id);

-- 4. Enable Real-time for this table
-- Use the publication typically named 'supabase_realtime'
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    IF NOT EXISTS (
      SELECT 1 FROM pg_publication_tables 
      WHERE pubname = 'supabase_realtime' 
      AND tablename = 'birthday_wishes' 
      AND schemaname = 'public'
    ) THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.birthday_wishes;
    END IF;
  END IF;
END $$;
