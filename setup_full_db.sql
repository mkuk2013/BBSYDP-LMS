-- COMPLETE DATABASE SETUP
-- Run this in Supabase SQL Editor to fix all table/column issues.

-- 1. Create Profiles Table (if missing)
-- We use 'uid' to match the chat.js code expectation.
CREATE TABLE IF NOT EXISTS public.profiles (
    uid UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT,
    role TEXT DEFAULT 'student',
    status TEXT DEFAULT 'offline',
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Ensure columns exist (if table already existed but was missing columns)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'uid') THEN
        ALTER TABLE public.profiles ADD COLUMN uid UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'status') THEN
        ALTER TABLE public.profiles ADD COLUMN status TEXT DEFAULT 'offline';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'last_active_at') THEN
        ALTER TABLE public.profiles ADD COLUMN last_active_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;

-- 3. Conversations Table
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_one UUID REFERENCES public.profiles(uid) ON DELETE CASCADE,
    user_two UUID REFERENCES public.profiles(uid) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_conversation_pair UNIQUE(user_one, user_two)
);

-- 4. Messages Table
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.profiles(uid) ON DELETE CASCADE,
    message TEXT,
    file_url TEXT,
    file_type TEXT,
    is_seen BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies (Drop first to avoid conflicts)
DROP POLICY IF EXISTS "Public profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can create conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can view messages" ON public.messages;
DROP POLICY IF EXISTS "Users can send messages" ON public.messages;
DROP POLICY IF EXISTS "Users can update seen" ON public.messages;

-- Profiles: Viewable by everyone, Update own.
CREATE POLICY "Public profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = uid);

-- Conversations
CREATE POLICY "Users can view own conversations" ON public.conversations FOR SELECT 
USING (auth.uid() = user_one OR auth.uid() = user_two);

CREATE POLICY "Users can create conversations" ON public.conversations FOR INSERT 
WITH CHECK (auth.uid() = user_one OR auth.uid() = user_two);

-- Messages
CREATE POLICY "Users can view messages" ON public.messages FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.conversations 
        WHERE id = conversation_id 
        AND (user_one = auth.uid() OR user_two = auth.uid())
    )
);

CREATE POLICY "Users can send messages" ON public.messages FOR INSERT 
WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can update seen" ON public.messages FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM public.conversations 
        WHERE id = conversation_id 
        AND (user_one = auth.uid() OR user_two = auth.uid())
    )
);

-- 7. Trigger to auto-create profile on signup (Optional but recommended)
-- This ensures 'profiles' always has a row for a new user.
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (uid, name, role)
  VALUES (new.id, new.raw_user_meta_data->>'name', 'student')
  ON CONFLICT (uid) DO NOTHING;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
