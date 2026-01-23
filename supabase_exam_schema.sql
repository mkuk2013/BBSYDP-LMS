-- Enable RLS
alter table if exists public.exam_results enable row level security;
alter table if exists public.exam_settings enable row level security;

-- Table: exam_settings
create table if not exists public.exam_settings (
    id int primary key,
    is_active boolean default false,
    updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Table: exam_results
create table if not exists public.exam_results (
    id uuid default gen_random_uuid() primary key,
    student_id uuid references auth.users(id) not null,
    student_name text,
    score int,
    total_marks int,
    status text,
    created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Policies for exam_settings
drop policy if exists "Allow read access to everyone for exam_settings" on public.exam_settings;
create policy "Allow read access to everyone for exam_settings"
on public.exam_settings for select using (true);

drop policy if exists "Allow update access to admins for exam_settings" on public.exam_settings;
create policy "Allow update access to admins for exam_settings"
on public.exam_settings for update using (
  auth.uid() in (select uid from public.profiles where role = 'admin')
);

drop policy if exists "Allow insert access to admins for exam_settings" on public.exam_settings;
create policy "Allow insert access to admins for exam_settings"
on public.exam_settings for insert with check (
  auth.uid() in (select uid from public.profiles where role = 'admin')
);

-- Policies for exam_results
drop policy if exists "Allow read access to own results for students" on public.exam_results;
create policy "Allow read access to own results for students"
on public.exam_results for select using (
  auth.uid() = student_id
);

drop policy if exists "Allow read access to all results for admins" on public.exam_results;
create policy "Allow read access to all results for admins"
on public.exam_results for select using (
  auth.uid() in (select uid from public.profiles where role = 'admin')
);

drop policy if exists "Allow insert access to students" on public.exam_results;
create policy "Allow insert access to students"
on public.exam_results for insert with check (
  auth.uid() = student_id
);

-- Insert default setting
insert into public.exam_settings (id, is_active)
values (1, false)
on conflict (id) do nothing;
