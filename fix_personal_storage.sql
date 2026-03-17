-- ==========================================
-- FIX PERSONAL STORAGE SCHEMA & PERMISSIONS
-- ==========================================

-- 1. Ensure all columns exist with correct types
ALTER TABLE public.personal_storage ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES public.profiles(uid) ON DELETE CASCADE;
ALTER TABLE public.personal_storage ADD COLUMN IF NOT EXISTS file_name TEXT;
ALTER TABLE public.personal_storage ADD COLUMN IF NOT EXISTS file_url TEXT;
ALTER TABLE public.personal_storage ADD COLUMN IF NOT EXISTS file_type TEXT;
ALTER TABLE public.personal_storage ADD COLUMN IF NOT EXISTS file_size INTEGER;
ALTER TABLE public.personal_storage ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- 2. Drop NOT NULL constraints on legacy columns that block new uploads
DO $$
BEGIN
    -- Drop NOT NULL from 'name' if it exists
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'personal_storage' AND column_name = 'name') THEN
        ALTER TABLE public.personal_storage ALTER COLUMN "name" DROP NOT NULL;
    END IF;

    -- Drop NOT NULL from 'url' if it exists
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'personal_storage' AND column_name = 'url') THEN
        ALTER TABLE public.personal_storage ALTER COLUMN "url" DROP NOT NULL;
    END IF;

    -- Drop NOT NULL from 'type' if it exists
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'personal_storage' AND column_name = 'type') THEN
        ALTER TABLE public.personal_storage ALTER COLUMN "type" DROP NOT NULL;
    END IF;

    -- Drop NOT NULL from 'size' if it exists
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'personal_storage' AND column_name = 'size') THEN
        ALTER TABLE public.personal_storage ALTER COLUMN "size" DROP NOT NULL;
    END IF;
END $$;

-- 3. Reset RLS Policies
ALTER TABLE public.personal_storage ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own storage" ON public.personal_storage;
DROP POLICY IF EXISTS "Admins view/delete all storage" ON public.personal_storage;
DROP POLICY IF EXISTS "Admins delete storage" ON public.personal_storage;
DROP POLICY IF EXISTS "Authenticated users manage own storage" ON public.personal_storage;

-- Updated Policies
CREATE POLICY "Users manage own storage" 
ON public.personal_storage FOR ALL 
TO authenticated 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins view all storage" 
ON public.personal_storage FOR SELECT 
TO authenticated 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins delete any storage" 
ON public.personal_storage FOR DELETE 
TO authenticated 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- 4. Grant Permissions
GRANT ALL ON public.personal_storage TO authenticated;
GRANT ALL ON public.personal_storage TO postgres;
GRANT ALL ON public.personal_storage TO service_role;

-- 5. Force the Supabase API to reload its schema cache
NOTIFY pgrst, 'reload schema';
