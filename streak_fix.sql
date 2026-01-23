-- Migration: Fix Login Streak
-- Purpose: Add persistent streak tracking to profiles

-- Add columns to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS login_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_login_date TEXT;

-- Comment for clarity
COMMENT ON COLUMN profiles.login_streak IS 'Consecutive days the student has logged in';
COMMENT ON COLUMN profiles.last_login_date IS 'Date of the last successful login to track daily streaks';
