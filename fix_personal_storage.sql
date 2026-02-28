-- It looks like your table has several columns from an older version of the schema 
-- (like 'name', 'url', etc.) that have NOT NULL constraints, while the new code uses 'file_name', 'file_url', etc.

-- Let's ensure the correct columns exist
ALTER TABLE public.personal_storage ADD COLUMN IF NOT EXISTS file_name TEXT;
ALTER TABLE public.personal_storage ADD COLUMN IF NOT EXISTS file_url TEXT;
ALTER TABLE public.personal_storage ADD COLUMN IF NOT EXISTS file_type TEXT;
ALTER TABLE public.personal_storage ADD COLUMN IF NOT EXISTS file_size INTEGER;

-- Drop NOT NULL constraints on legacy columns that block new uploads
DO $$
BEGIN
    -- Drop NOT NULL from 'name'
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'personal_storage' AND column_name = 'name') THEN
        ALTER TABLE public.personal_storage ALTER COLUMN "name" DROP NOT NULL;
    END IF;

    -- Drop NOT NULL from 'url'
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'personal_storage' AND column_name = 'url') THEN
        ALTER TABLE public.personal_storage ALTER COLUMN "url" DROP NOT NULL;
    END IF;

    -- Drop NOT NULL from 'type' (just in case)
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'personal_storage' AND column_name = 'type') THEN
        ALTER TABLE public.personal_storage ALTER COLUMN "type" DROP NOT NULL;
    END IF;

    -- Drop NOT NULL from 'size' (just in case)
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'personal_storage' AND column_name = 'size') THEN
        ALTER TABLE public.personal_storage ALTER COLUMN "size" DROP NOT NULL;
    END IF;
END $$;

-- Force the Supabase API to reload its schema cache
NOTIFY pgrst, 'reload schema';
