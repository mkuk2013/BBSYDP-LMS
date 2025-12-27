-- Add progress columns for Drag Game if not exists
ALTER TABLE public.user_arcade_progress 
ADD COLUMN IF NOT EXISTS drag_level text default 'easy';

-- Ensure existing columns just in case
ALTER TABLE public.user_arcade_progress 
ADD COLUMN IF NOT EXISTS html_level text default 'easy';

ALTER TABLE public.user_arcade_progress 
ADD COLUMN IF NOT EXISTS css_level text default 'easy';
