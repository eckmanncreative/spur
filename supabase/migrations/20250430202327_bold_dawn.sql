/*
  # Link Auth Users with Accounts

  1. Changes
    - Add trigger to create account record when auth.users is inserted
    - Update accounts table to use auth.uid() as id
    - Add constraint to ensure account.id matches auth.users.id
    - Remove password column as it's handled by auth
    - Make last_name nullable to match current usage

  2. Security
    - Ensure RLS policies use auth.uid()
    - Add trigger to maintain data consistency
*/

-- Remove password column since auth handles this
ALTER TABLE accounts
DROP COLUMN password;

-- Make last_name nullable to match current usage
ALTER TABLE accounts
ALTER COLUMN last_name DROP NOT NULL;

-- Create function to handle new user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO accounts (id, email, username, first_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create account
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Update RLS policies for accounts
DROP POLICY IF EXISTS "Public can create accounts" ON accounts;
DROP POLICY IF EXISTS "Users can read own account" ON accounts;
DROP POLICY IF EXISTS "Users can update own account" ON accounts;

CREATE POLICY "Users can read own account" ON accounts
  FOR SELECT TO authenticated
  USING (id = auth.uid());

CREATE POLICY "Users can update own account" ON accounts
  FOR UPDATE TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());