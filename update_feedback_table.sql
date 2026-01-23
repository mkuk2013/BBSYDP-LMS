-- Add new columns for advanced feedback
alter table feedback 
add column if not exists instructor_quality text,
add column if not exists course_pace text,
add column if not exists would_recommend text; -- storing as text for 'yes'/'no' or boolean

-- Optional: Update RLS policies if needed (usually not for adding columns if insert policy exists)
