-- ============================================================================
-- SECURE RLS POLICIES FOR SUPER BOWL POOL
-- ============================================================================
-- Run this SQL in your Supabase SQL Editor to set up secure Row Level Security
-- 
-- This will:
-- 1. Enable RLS on all tables
-- 2. Drop any existing insecure policies
-- 3. Create new policies that require authentication for writes
-- ============================================================================

-- ============================================================================
-- ENTRIES TABLE
-- ============================================================================

-- Enable RLS
ALTER TABLE entries ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies (if any)
DROP POLICY IF EXISTS "Public read access" ON entries;
DROP POLICY IF EXISTS "Public insert access" ON entries;
DROP POLICY IF EXISTS "Public update access" ON entries;
DROP POLICY IF EXISTS "Public delete access" ON entries;
DROP POLICY IF EXISTS "Authenticated update access" ON entries;
DROP POLICY IF EXISTS "Authenticated delete access" ON entries;

-- Allow anyone to read all entries (needed for public scoreboard)
CREATE POLICY "Public read access" ON entries
  FOR SELECT 
  USING (true);

-- Allow anyone to insert new entries (submit an entry)
CREATE POLICY "Public insert access" ON entries
  FOR INSERT 
  WITH CHECK (true);

-- Only authenticated users can update entries (admin only)
CREATE POLICY "Authenticated update access" ON entries
  FOR UPDATE 
  USING (auth.uid() IS NOT NULL);

-- Only authenticated users can delete entries (admin only)
CREATE POLICY "Authenticated delete access" ON entries
  FOR DELETE 
  USING (auth.uid() IS NOT NULL);


-- ============================================================================
-- QUESTIONS TABLE
-- ============================================================================

-- Enable RLS
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies (if any)
DROP POLICY IF EXISTS "Public read access" ON questions;
DROP POLICY IF EXISTS "Public update access" ON questions;
DROP POLICY IF EXISTS "Authenticated update access" ON questions;

-- Allow anyone to read questions
CREATE POLICY "Public read access" ON questions
  FOR SELECT 
  USING (true);

-- Only authenticated users can update questions (admin only)
CREATE POLICY "Authenticated update access" ON questions
  FOR UPDATE 
  USING (auth.uid() IS NOT NULL);


-- ============================================================================
-- CORRECT_ANSWERS TABLE
-- ============================================================================

-- Enable RLS
ALTER TABLE correct_answers ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies (if any)
DROP POLICY IF EXISTS "Public read access" ON correct_answers;
DROP POLICY IF EXISTS "Public update access" ON correct_answers;
DROP POLICY IF EXISTS "Authenticated update access" ON correct_answers;

-- Allow anyone to read correct answers (needed to display scores)
CREATE POLICY "Public read access" ON correct_answers
  FOR SELECT 
  USING (true);

-- Only authenticated users can update answers/settings (admin only)
CREATE POLICY "Authenticated update access" ON correct_answers
  FOR UPDATE 
  USING (auth.uid() IS NOT NULL);


-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- To verify your policies are in place, run:
--
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
-- FROM pg_policies
-- WHERE schemaname = 'public'
-- ORDER BY tablename, policyname;
-- ============================================================================
