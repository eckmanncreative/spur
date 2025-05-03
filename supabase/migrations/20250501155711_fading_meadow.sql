/*
  # Update accounts table for new signup flow
  
  1. Changes
    - Add display_name column for user-facing name
    - Update constraints and indexes
    - Update RLS policies
    
  2. Security
    - Maintain RLS policies
    - Add proper validation checks
*/

-- Update accounts table
ALTER TABLE accounts
  ALTER COLUMN first_name DROP NOT NULL,
  ALTER COLUMN display_name DROP NOT NULL;

-- Update constraints with better error messages
ALTER TABLE accounts DROP CONSTRAINT IF EXISTS display_name_length;
ALTER TABLE accounts ADD CONSTRAINT display_name_length 
  CHECK (char_length(display_name) >= 3) 
  NOT VALID;

-- Create indexes for new columns
CREATE INDEX IF NOT EXISTS accounts_display_name_idx ON accounts USING btree (display_name);

-- Update RLS policies
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