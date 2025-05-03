/*
  # Update accounts table schema
  
  1. Changes
    - Update column constraints for accounts table
    - Add validation constraints for username and email
    - Update RLS policies for better auth integration
  
  2. Security
    - Maintain RLS policies for proper access control
    - Keep service role access for Supabase Auth
*/

-- Update table constraints
ALTER TABLE accounts
  ALTER COLUMN created_at SET DEFAULT now(),
  ALTER COLUMN updated_at SET DEFAULT now(),
  ALTER COLUMN first_name SET NOT NULL,
  ALTER COLUMN email SET NOT NULL,
  ALTER COLUMN username SET NOT NULL;

-- Add basic constraints
ALTER TABLE accounts DROP CONSTRAINT IF EXISTS username_length;
ALTER TABLE accounts DROP CONSTRAINT IF EXISTS email_valid;

ALTER TABLE accounts 
  ADD CONSTRAINT username_length 
  CHECK (char_length(username) >= 3);

ALTER TABLE accounts 
  ADD CONSTRAINT email_valid 
  CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Ensure unique constraints
ALTER TABLE accounts DROP CONSTRAINT IF EXISTS accounts_username_key;
ALTER TABLE accounts DROP CONSTRAINT IF EXISTS accounts_email_key;

ALTER TABLE accounts
  ADD CONSTRAINT accounts_username_key UNIQUE (username),
  ADD CONSTRAINT accounts_email_key UNIQUE (email);

-- Update RLS policies
DROP POLICY IF EXISTS "Service role can manage all accounts" ON accounts;
DROP POLICY IF EXISTS "Allow account creation during signup" ON accounts;
DROP POLICY IF EXISTS "Users can read own account" ON accounts;
DROP POLICY IF EXISTS "Users can update own account" ON accounts;

-- Recreate policies with simplified access control
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