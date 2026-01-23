-- Enable Row Level Security
alter table feedback enable row level security;

-- Policy to allow users to insert their own feedback (if not already present)
create policy "Users can insert their own feedback"
on feedback for insert
with check (auth.uid() = student_id);

-- Policy to allow users to view their own feedback (CRITICAL for popup check)
create policy "Users can view their own feedback"
on feedback for select
using (auth.uid() = student_id);
