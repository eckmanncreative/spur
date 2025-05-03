/*
  # Fix user creation trigger

  1. Changes
    - Drop existing trigger function
    - Create new trigger function that properly handles user creation
    - Add trigger to auth.users table
    
  2. Security
    - Maintains RLS policies
    - Preserves existing constraints
*/

-- Drop existing trigger if it exists
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- Create new trigger function
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- Check if account already exists
  IF NOT EXISTS (
    SELECT 1 FROM accounts WHERE id = NEW.id
  ) THEN
    -- Insert new account
    INSERT INTO accounts (
      id,
      email,
      username,
      first_name,
      last_name,
      created_at,
      updated_at
    ) VALUES (
      NEW.id,
      NEW.email,
      COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
      COALESCE(NEW.raw_user_meta_data->>'first_name', split_part(NEW.email, '@', 1)),
      NEW.raw_user_meta_data->>'last_name',
      NEW.created_at,
      NEW.updated_at
    );
  END IF;

  -- Create default profile
  INSERT INTO profiles (account_id, name)
  VALUES (NEW.id, 'Personal')
  ON CONFLICT DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();