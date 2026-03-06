-- ============================================================================
-- DATABASE RESTORE — Super Bowl Pool (post-2026 reset)
-- Generated: 2026-02-26
-- ============================================================================
-- Restores the database to its current state as of 2026-02-26:
--   • Schema (3 tables)
--   • Questions (template placeholders, ready to edit for 2027)
--   • correct_answers config row (zeroed, entries closed)
--   • entries table (empty — reset already run)
--   • RLS policies
-- ============================================================================
--
-- ============================================================================
-- FULL REBUILD GUIDE (if Supabase deletes or pauses the project)
-- ============================================================================
--
-- STEP A — Create a new Supabase project
--   1. Go to https://supabase.com and sign in
--   2. Click "New project"
--   3. Name it:  sbteaser   (or anything you like — the name doesn't matter
--                            to the app, only the URL and anon key do)
--   4. Set a strong database password and save it somewhere safe
--   5. Choose a region close to you (e.g. US West)
--   6. Wait for the project to finish provisioning (~1 min)
--
-- STEP B — Run this SQL script
--   1. In your new project, go to SQL Editor (left sidebar)
--   2. Paste the entire contents of this file and click Run
--   3. Confirm with the verification queries at the bottom
--
-- STEP C — Re-create the admin user (Supabase Authentication)
--   The app logs in via Supabase Auth (email + password), NOT a database table.
--   You must recreate your admin account manually:
--   1. Go to Authentication → Users (left sidebar)
--   2. Click "Add user" → "Create new user"
--   3. Enter your admin email and a strong password
--   4. Click "Create user"
--   That's it — no other auth config is needed.
--
-- STEP D — Update index.html with the new project credentials
--   1. In your new Supabase project, go to Project Settings → API
--   2. Copy "Project URL" and "anon / public" key
--   3. Open index.html and replace the two constants near the top:
--
--        const SUPABASE_URL = 'https://<new-project-ref>.supabase.co';
--        const SUPABASE_ANON_KEY = '<new-anon-key>';
--
--   The current values (for the original project) are:
--        SUPABASE_URL     = 'https://eggswgehszlqosxyxfap.supabase.co'
--        SUPABASE_ANON_KEY = (see index.html line ~29)
--
-- ============================================================================


-- ============================================================================
-- STEP 1 — TABLE SCHEMA
-- ============================================================================

CREATE TABLE IF NOT EXISTS entries (
  id           bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name         text        NOT NULL,
  email        text,
  mobile       text,
  answers_bits integer     NOT NULL DEFAULT 0,
  tiebreaker   integer     NOT NULL DEFAULT 0,
  paid         boolean     NOT NULL DEFAULT false,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS questions (
  id        integer PRIMARY KEY,
  questions jsonb   NOT NULL
);

CREATE TABLE IF NOT EXISTS correct_answers (
  id                  integer PRIMARY KEY,
  answers_bits        integer,
  answered_mask       integer,
  entries_open        boolean,
  actual_total_points integer
);


-- ============================================================================
-- STEP 2 — SEED DATA
-- ============================================================================

-- questions: current as of 2026-02-26 (template placeholders, edit for 2027)
INSERT INTO questions (id, questions) VALUES (
  1,
  '[
    "________ will take longer than 2:00 to sing the National Anthem",
    "HOME will win the coin toss",
    "The first commercial after kickoff will be for a food or beverage",
    "The first penalty will be called against HOME",
    "The first points of the game will be scored on a field goal",
    "HOME will score the first points of the game",
    "HOME will score on their first possession of the game",
    "AWAY will score on their first possession of the game",
    "Halftime show question",
    "HOME will be the first team to call a timeout",
    "There will be a fumble in the game recovered by the opposing team",
    "A team will convert on 4th down",
    "A team will attempt a 2-point conversion after a touchdown",
    "A player other than the starting quarterbacks will attempt a forward pass",
    "The game will be tied again after 0-0 (after extra point attempts)",
    "The game including halftime will end by 7:20 pm PST (3:50 duration)",
    "The total points scored in the game will be more than 45.5",
    "There will be more points scored before halftime than after halftime",
    "The team that wins the coin toss will also win the game",
    "HOME will win the game"
  ]'::jsonb
)
ON CONFLICT (id) DO UPDATE SET questions = EXCLUDED.questions;

-- correct_answers: zeroed out after reset, entries closed
INSERT INTO correct_answers (id, answers_bits, answered_mask, entries_open, actual_total_points)
VALUES (1, 0, 0, false, NULL)
ON CONFLICT (id) DO UPDATE
  SET answers_bits        = 0,
      answered_mask       = 0,
      entries_open        = false,
      actual_total_points = NULL;

-- entries: empty after reset — nothing to insert.


-- ============================================================================
-- STEP 3 — ROW LEVEL SECURITY (from setup-rls-policies.sql)
-- ============================================================================

-- ---- entries ---------------------------------------------------------------
ALTER TABLE entries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read access"          ON entries;
DROP POLICY IF EXISTS "Public insert access"        ON entries;
DROP POLICY IF EXISTS "Public update access"        ON entries;
DROP POLICY IF EXISTS "Public delete access"        ON entries;
DROP POLICY IF EXISTS "Authenticated update access" ON entries;
DROP POLICY IF EXISTS "Authenticated delete access" ON entries;

CREATE POLICY "Public read access" ON entries
  FOR SELECT USING (true);

CREATE POLICY "Public insert access" ON entries
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Authenticated update access" ON entries
  FOR UPDATE USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated delete access" ON entries
  FOR DELETE USING (auth.uid() IS NOT NULL);

-- ---- questions -------------------------------------------------------------
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read access"          ON questions;
DROP POLICY IF EXISTS "Public update access"        ON questions;
DROP POLICY IF EXISTS "Authenticated update access" ON questions;

CREATE POLICY "Public read access" ON questions
  FOR SELECT USING (true);

CREATE POLICY "Authenticated update access" ON questions
  FOR UPDATE USING (auth.uid() IS NOT NULL);

-- ---- correct_answers -------------------------------------------------------
ALTER TABLE correct_answers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read access"          ON correct_answers;
DROP POLICY IF EXISTS "Public update access"        ON correct_answers;
DROP POLICY IF EXISTS "Authenticated update access" ON correct_answers;

CREATE POLICY "Public read access" ON correct_answers
  FOR SELECT USING (true);

CREATE POLICY "Authenticated update access" ON correct_answers
  FOR UPDATE USING (auth.uid() IS NOT NULL);


-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- SELECT COUNT(*) FROM entries;                          -- expect 0
-- SELECT answers_bits, answered_mask, entries_open, actual_total_points
--   FROM correct_answers WHERE id = 1;                  -- 0, 0, false, NULL
-- SELECT jsonb_array_length(questions) FROM questions WHERE id = 1;  -- 20
-- ============================================================================
