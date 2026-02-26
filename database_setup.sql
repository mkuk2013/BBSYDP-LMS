-- ==============================================================================
-- NAVTTC LMS Complete Database Schema & RLS Policies Setup
-- ==============================================================================
-- Run this entire script in your Supabase SQL Editor.
-- It creates all required tables, sets up relationships, enables Row Level Security (RLS),
-- and applies the necessary policies for Students and Admins.

-- 1. Create Tables

-- Profiles Table (Linked to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    uid UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT DEFAULT 'student' CHECK (role IN ('student', 'admin')),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved')),
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tasks Table
CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    hints TEXT,
    deadline TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Submissions Table
CREATE TABLE IF NOT EXISTS public.submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE,
    student_id UUID REFERENCES public.profiles(uid) ON DELETE CASCADE,
    content JSONB,
    status TEXT DEFAULT 'submitted' CHECK (status IN ('submitted', 'graded')),
    grade INTEGER,
    feedback TEXT,
    submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- Resources Table
CREATE TABLE IF NOT EXISTS public.resources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    category TEXT,
    url TEXT,
    added_by UUID REFERENCES public.profiles(uid) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Task Comments / Threading Table
CREATE TABLE IF NOT EXISTS public.task_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(uid) ON DELETE CASCADE,
    user_name TEXT,
    role TEXT,
    content TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Exam Settings Table (Singleton)
CREATE TABLE IF NOT EXISTS public.exam_settings (
    id SERIAL PRIMARY KEY,
    is_active BOOLEAN DEFAULT false,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Initialize exam_settings row
INSERT INTO public.exam_settings (id, is_active) VALUES (1, false) ON CONFLICT (id) DO NOTHING;

-- Exam Results Table
CREATE TABLE IF NOT EXISTS public.exam_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES public.profiles(uid) ON DELETE CASCADE,
    score NUMERIC,
    total_marks NUMERIC,
    answers JSONB,
    certificate_id TEXT,
    submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notices / Announcements Table
CREATE TABLE IF NOT EXISTS public.notices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT,
    content TEXT,
    type TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Achievements (Badges)
CREATE TABLE IF NOT EXISTS public.user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(uid) ON DELETE CASCADE,
    badge_key TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, badge_key)
);

-- User Arcade Progress
CREATE TABLE IF NOT EXISTS public.user_arcade_progress (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(uid) ON DELETE CASCADE,
    html_level TEXT DEFAULT 'easy',
    css_level TEXT DEFAULT 'easy',
    js_level TEXT DEFAULT 'easy',
    syntax_balloons_score INTEGER DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Course Feedback Table
CREATE TABLE IF NOT EXISTS public.feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID UNIQUE REFERENCES public.profiles(uid) ON DELETE CASCADE,
    instructor_rating INTEGER,
    course_rating INTEGER,
    pace_rating INTEGER,
    support_rating INTEGER,
    enjoyed_most TEXT,
    needs_improvement TEXT,
    additional_comments TEXT,
    submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- Arcade Config Table (Singleton)
CREATE TABLE IF NOT EXISTS public.arcade_config (
    id SERIAL PRIMARY KEY,
    is_unlocked BOOLEAN DEFAULT false,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Initialize arcade_config
INSERT INTO public.arcade_config (id, is_unlocked) VALUES (1, false) ON CONFLICT (id) DO NOTHING;

-- Personal Storage Table (Student Drive)
CREATE TABLE IF NOT EXISTS public.personal_storage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(uid) ON DELETE CASCADE,
    file_name TEXT,
    file_url TEXT,
    file_type TEXT,
    file_size INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Global Messages (Admin Chat Broadcasts)
CREATE TABLE IF NOT EXISTS public.global_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(uid) ON DELETE CASCADE,
    user_name TEXT,
    role TEXT,
    content TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Avatars (Library)
CREATE TABLE IF NOT EXISTS public.avatars (
    id SERIAL PRIMARY KEY,
    url TEXT NOT NULL,
    type TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ==============================================================================
-- 2. Enable Row Level Security (RLS)
-- ==============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_arcade_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.arcade_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.personal_storage ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.global_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.avatars ENABLE ROW LEVEL SECURITY;


-- ==============================================================================
-- 3. Define RLS Policies
-- ==============================================================================

-- PROFILES: Everyone can read, users can update their own, insert their own.
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = uid);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = uid);
CREATE POLICY "Admins can update any profile" ON public.profiles FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admins can delete profiles" ON public.profiles FOR DELETE USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
);

-- TASKS: Everyone can read, only admins can manage
CREATE POLICY "Tasks are viewable by everyone" ON public.tasks FOR SELECT USING (true);
CREATE POLICY "Admins can insert tasks" ON public.tasks FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));
CREATE POLICY "Admins can update tasks" ON public.tasks FOR UPDATE USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));
CREATE POLICY "Admins can delete tasks" ON public.tasks FOR DELETE USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- SUBMISSIONS: Students can see their own, admins can see all. Students insert/update their own. Admins can update/delete any.
CREATE POLICY "Students see own submissions, admins see all" ON public.submissions FOR SELECT USING (
    auth.uid() = student_id OR EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
);
CREATE POLICY "Students insert own submissions" ON public.submissions FOR INSERT WITH CHECK (auth.uid() = student_id);
CREATE POLICY "Students and Admins can update submissions" ON public.submissions FOR UPDATE USING (
    auth.uid() = student_id OR EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admins can delete any submission, students delete own" ON public.submissions FOR DELETE USING (
    auth.uid() = student_id OR EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
);

-- RESOURCES: Everyone can select. Admins manage.
CREATE POLICY "Resources are viewable by everyone" ON public.resources FOR SELECT USING (true);
CREATE POLICY "Admins can manage resources" ON public.resources FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- TASK COMMENTS: Everyone can select. Users can insert. Users can manage their own, admins manage all.
CREATE POLICY "Comments viewable by everyone" ON public.task_comments FOR SELECT USING (true);
CREATE POLICY "Users can insert comments" ON public.task_comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins manage all comments, users manage own" ON public.task_comments FOR ALL USING (
    auth.uid() = user_id OR EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
);

-- EXAM SETTINGS: Everyone can read. Admins manage.
CREATE POLICY "Exam settings viewable by everyone" ON public.exam_settings FOR SELECT USING (true);
CREATE POLICY "Admins manage exam settings" ON public.exam_settings FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- EXAM RESULTS: Public read (for certificate verification). Students insert their own. Admins manage all.
CREATE POLICY "Public read for exam results" ON public.exam_results FOR SELECT USING (true);
CREATE POLICY "Students insert own results" ON public.exam_results FOR INSERT WITH CHECK (auth.uid() = student_id);
CREATE POLICY "Students update own, admins update all" ON public.exam_results FOR UPDATE USING (
    auth.uid() = student_id OR EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admins can delete results" ON public.exam_results FOR DELETE USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- NOTICES: Everyone can read. Admins manage.
CREATE POLICY "Notices viewable by everyone" ON public.notices FOR SELECT USING (true);
CREATE POLICY "Admins manage notices" ON public.notices FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- USER ACHIEVEMENTS / ARCADE: Everyone can read. Users insert/update own. Admins manage.
CREATE POLICY "Achievements viewable by everyone" ON public.user_achievements FOR SELECT USING (true);
CREATE POLICY "Manage achievements" ON public.user_achievements FOR ALL USING (
    auth.uid() = user_id OR EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
);

CREATE POLICY "Arcade progress viewable by everyone" ON public.user_arcade_progress FOR SELECT USING (true);
CREATE POLICY "Manage arcade progress" ON public.user_arcade_progress FOR ALL USING (
    auth.uid() = user_id OR EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
);

-- FEEDBACK: Admins can read all. Students insert and read their own.
CREATE POLICY "Students read own feedback, Admins read all" ON public.feedback FOR SELECT USING (
    auth.uid() = student_id OR EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
);
CREATE POLICY "Students insert feedback" ON public.feedback FOR INSERT WITH CHECK (auth.uid() = student_id);
CREATE POLICY "Admins manage all feedback" ON public.feedback FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- ARCADE CONFIG: Everyone read. Admin manage.
CREATE POLICY "Arcade config viewable by everyone" ON public.arcade_config FOR SELECT USING (true);
CREATE POLICY "Admins manage arcade config" ON public.arcade_config FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- PERSONAL STORAGE: Users manage their own. Admins can view/delete.
CREATE POLICY "Users manage own storage" ON public.personal_storage FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Admins view/delete all storage" ON public.personal_storage FOR SELECT USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));
CREATE POLICY "Admins delete storage" ON public.personal_storage FOR DELETE USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- GLOBAL MESSAGES: Everyone reads. Everyone inserts? Or admin inserts? The code says admin broadcasts usually. 
-- We'll allow authenticated users to insert logic.
CREATE POLICY "Global messages viewable by everyone" ON public.global_messages FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert global messages" ON public.global_messages FOR INSERT WITH CHECK (auth.uid() = user_id);

-- AVATARS: Everyone reads. Admins manage.
CREATE POLICY "Avatars viewable by everyone" ON public.avatars FOR SELECT USING (true);
CREATE POLICY "Admins manage avatars" ON public.avatars FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));


-- ==============================================================================
-- 4. Create Utility RPC Functions
-- ==============================================================================

-- Function to completely delete a user and their auth account from Supabase
-- Requires SECURITY DEFINER so it runs with admin privileges
CREATE OR REPLACE FUNCTION delete_user_via_admin(target_uid UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Delete the user from auth.users (This will cascade to public.profiles and others)
    DELETE FROM auth.users WHERE id = target_uid;
END;
$$;
