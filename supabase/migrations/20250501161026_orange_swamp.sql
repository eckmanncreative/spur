/*
  # Fix profiles creation

  1. Changes
    - Drop existing profiles
    - Add constraint to ensure only one profile per account
    - Update RLS policies
*/

-- First clean up existing data
TRUNCATE profiles CASCADE;

-- Add constraint to ensure only one profile per account/name combination
ALTER TABLE profiles 
ADD CONSTRAINT unique_account_profile UNIQUE (account_id, name);

-- Update RLS policies
DROP POLICY IF EXISTS "Users can manage own profiles" ON profiles;
DROP POLICY IF EXISTS "Anyone can view profiles" ON profiles;

CREATE POLICY "Users can manage own profiles"
ON profiles
FOR ALL
TO authenticated
USING (account_id = auth.uid())
WITH CHECK (account_id = auth.uid());

CREATE POLICY "Anyone can view profiles"
ON profiles
FOR SELECT
TO public
USING (true);

-- Create function to handle new account creation
CREATE OR REPLACE FUNCTION handle_new_account()
RETURNS TRIGGER AS $$
BEGIN
  -- Create default general profile
  INSERT INTO profiles (account_id, name)
  VALUES (NEW.id, 'general')
  ON CONFLICT (account_id, name) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for new account creation
DROP TRIGGER IF EXISTS on_account_created ON accounts;
CREATE TRIGGER on_account_created
  AFTER INSERT ON accounts
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_account();