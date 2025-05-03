/*
  # Fix profile creation trigger

  1. Changes
    - Drop existing trigger and function
    - Create new trigger function that properly creates the default profile
    - Add trigger to accounts table
    
  2. Security
    - Maintains existing RLS policies
    - Preserves data integrity
*/

-- Drop existing trigger and function
DROP TRIGGER IF EXISTS on_account_created ON accounts;
DROP FUNCTION IF EXISTS handle_new_account();

-- Create new trigger function
CREATE OR REPLACE FUNCTION handle_new_account()
RETURNS TRIGGER AS $$
BEGIN
  -- Create default general profile
  INSERT INTO profiles (account_id, name)
  VALUES (NEW.id, 'Personal')
  ON CONFLICT DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new account creation
CREATE TRIGGER on_account_created
  AFTER INSERT ON accounts
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_account();

-- Create default profiles for existing accounts
INSERT INTO profiles (account_id, name)
SELECT id, 'Personal'
FROM accounts
WHERE NOT EXISTS (
  SELECT 1 FROM profiles 
  WHERE profiles.account_id = accounts.id
  AND profiles.name = 'Personal'
);