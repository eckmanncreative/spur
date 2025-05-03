/*
  # Update schema to use display_name
  
  1. Changes
    - Rename username column to display_name
    - Update constraints and policies to use display_name
    - Remove any remaining triggers
  
  2. Security
    - Maintain RLS policies with updated column names
    - Keep existing access control patterns
*/

-- Rename username column to display_name
ALTER TABLE accounts RENAME COLUMN username TO display_name;

-- Update constraints for display_name
ALTER TABLE accounts DROP CONSTRAINT IF EXISTS username_length;
ALTER TABLE accounts DROP CONSTRAINT IF EXISTS accounts_username_key;
ALTER TABLE accounts ADD CONSTRAINT display_name_length CHECK (char_length(display_name) >= 3);
ALTER TABLE accounts ADD CONSTRAINT accounts_display_name_key UNIQUE (display_name);

-- Drop existing indexes for username
DROP INDEX IF EXISTS accounts_username_idx;
DROP INDEX IF EXISTS accounts_username_key;

-- Create new indexes for display_name
CREATE INDEX accounts_display_name_idx ON accounts USING btree (display_name);

-- Update table constraints
ALTER TABLE accounts
  ALTER COLUMN created_at SET DEFAULT now(),
  ALTER COLUMN updated_at SET DEFAULT now(),
  ALTER COLUMN email SET NOT NULL,
  ALTER COLUMN display_name SET NOT NULL;

-- Ensure email validation
ALTER TABLE accounts DROP CONSTRAINT IF EXISTS email_valid;
ALTER TABLE accounts ADD CONSTRAINT email_valid 
  CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Recreate RLS policies
DROP POLICY IF EXISTS "Service role can manage all accounts" ON accounts;
DROP POLICY IF EXISTS "Allow account creation during signup" ON accounts;
DROP POLICY IF EXISTS "Users can read own account" ON accounts;
DROP POLICY IF EXISTS "Users can update own account" ON accounts;

CREATE POLICY "Service role can manage all accounts"
ON accounts FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow account creation during signup"
ON accounts FOR INSERT
TO authenticated, anon
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can read own account"
ON accounts FOR SELECT
TO authenticated
USING (id = auth.uid());

CREATE POLICY "Users can update own account"
ON accounts FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Ensure RLS is enabled
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;