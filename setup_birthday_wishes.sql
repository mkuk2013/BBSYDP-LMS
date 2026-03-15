-- ==============================================================================
-- Birthday wishes Table & RLS Policies Setup
-- ==============================================================================

-- 1. Create table
CREATE TABLE IF NOT EXISTS public.birthday_wishes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES public.profiles(uid) ON DELETE CASCADE,
    student_name TEXT,
    admin_name TEXT,
    replied BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable RLS
ALTER TABLE public.birthday_wishes ENABLE ROW LEVEL SECURITY;

-- 3. Define Policies

-- Admins can view all wishes
CREATE POLICY "Admins can view all wishes" 
ON public.birthday_wishes FOR SELECT 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- Admins can update all wishes (for replied status)
CREATE POLICY "Admins can update wishes" 
ON public.birthday_wishes FOR UPDATE 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

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
    ALTER PUBLICATION supabase_realtime ADD TABLE public.birthday_wishes;
  END IF;
END $$;
