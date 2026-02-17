# Security Migration Guide

## What Changed

Your app now uses **Supabase Authentication** instead of a custom Edge Function for admin access. This is more secure because:

- ✅ All database operations automatically include authentication
- ✅ RLS policies enforce security at the database level
- ✅ Cannot be bypassed with browser dev tools
- ✅ Simpler architecture (no custom Edge Function needed)

## Migration Steps

### 1. Apply RLS Policies

1. Go to your Supabase dashboard → **SQL Editor**
2. Open the file `setup-rls-policies.sql` 
3. Copy and paste the entire SQL into the editor
4. Click **Run** to apply the policies

This will:
- Enable Row Level Security on all tables
- Remove the insecure "public" write policies
- Create secure policies that require authentication for updates/deletes

### 2. Test Admin Login

1. Open your app in a browser
2. Navigate to the login page
3. Use your **Supabase user email** (not a username) and password
4. You should be logged in and see the admin panel

**Important:** The login now expects an **email address**, not a username.

### 3. Verify Security

Try these tests in an incognito/private browser window (not logged in):

**Should work:**
- ✅ View the entry form
- ✅ View scores page
- ✅ Submit a new entry

**Should fail:**
- ❌ Update payment status on an entry
- ❌ Delete any entries
- ❌ Update questions
- ❌ Update correct answers

If any of the "should fail" operations work without logging in, the RLS policies didn't apply correctly.

### 4. Clean Up Old Code (Optional)

Once everything is working, you can delete:

1. **Supabase Edge Function:** `verify-admin` (in your Supabase dashboard → Edge Functions)
2. **Database Table:** `admin_users` (in your Supabase dashboard → Table Editor)

These are no longer used.

## Rollback Plan

If something goes wrong, you can rollback by:

1. Going to Supabase → SQL Editor
2. Running this SQL to restore public access (temporarily):

```sql
DROP POLICY IF EXISTS "Authenticated update access" ON entries;
DROP POLICY IF EXISTS "Authenticated delete access" ON entries;
DROP POLICY IF EXISTS "Authenticated update access" ON questions;
DROP POLICY IF EXISTS "Authenticated update access" ON correct_answers;

CREATE POLICY "Public update access" ON entries FOR UPDATE USING (true);
CREATE POLICY "Public delete access" ON entries FOR DELETE USING (true);
CREATE POLICY "Public update access" ON questions FOR UPDATE USING (true);
CREATE POLICY "Public update access" ON correct_answers FOR UPDATE USING (true);
```

⚠️ **Warning:** This makes your database insecure again!

## Troubleshooting

**"Invalid credentials" error when logging in:**
- Make sure you're using your **email address**, not a username
- Verify the user exists in Supabase → Authentication → Users
- Check that the password is correct

**Admin operations fail with "new row violates row-level security policy":**
- You're not properly authenticated
- Try logging out and back in
- Check browser console for session errors

**Can't update/delete even when logged in:**
- Clear your browser cache and cookies
- Make sure the RLS policies were applied (check SQL Editor)
- Verify you're using the correct Supabase URL/anon key
