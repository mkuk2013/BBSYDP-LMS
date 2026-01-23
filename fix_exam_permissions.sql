-- Fix for Admin Reset Exam Functionality
-- Run this in your Supabase SQL Editor

-- 1. Enable RLS on exam_results (if not already enabled, just to be safe)
alter table public.exam_results enable row level security;

-- 2. Create Policy to allow Admins to DELETE exam results
drop policy if exists "Allow delete access to admins for exam_results" on public.exam_results;

create policy "Allow delete access to admins for exam_results"
on public.exam_results for delete using (
  auth.uid() in (select uid from public.profiles where role = 'admin')
);

-- 3. (Optional) Create Policy to allow Admins to UPDATE exam results (if needed later)
drop policy if exists "Allow update access to admins for exam_results" on public.exam_results;

create policy "Allow update access to admins for exam_results"
on public.exam_results for update using (
  auth.uid() in (select uid from public.profiles where role = 'admin')
);

-- 4. Verify policies
select * from pg_policies where tablename = 'exam_results';
