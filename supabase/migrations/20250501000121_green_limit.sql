/*
  # Fix accounts table constraints and triggers

  1. Changes
    - Add trigger to handle user creation and validation
    - Add function to validate and create users
    - Modify email validation to match auth.users
    - Add proper error messages for constraints

  2. Security
    - Maintain RLS policies
    - Add proper validation checks
*/

-- Create a function to validate and handle user creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Validate username length
  IF char_length(NEW.username) < 3 THEN
    RAISE EXCEPTION 'Username must be at least 3 characters long';
  END IF;

  -- Validate email format
  IF NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
    RAISE EXCEPTION 'Invalid email format';
  END IF;

  -- Check for duplicate username
  IF EXISTS (
    SELECT 1 FROM accounts 
    WHERE username = NEW.username 
    AND id != NEW.id
  ) THEN
    RAISE EXCEPTION 'Username already taken';
  END IF;

  -- Check for duplicate email
  IF EXISTS (
    SELECT 1 FROM accounts 
    WHERE email = NEW.email 
    AND id != NEW.id
  ) THEN
    RAISE EXCEPTION 'Email already registered';
  END IF;

  -- Set timestamps
  NEW.created_at := COALESCE(NEW.created_at, now());
  NEW.updated_at := now();

  -- Ensure first_name is not empty
  IF NEW.first_name IS NULL OR trim(NEW.first_name) = '' THEN
    NEW.first_name := NEW.username;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS handle_new_user_trigger ON accounts;

-- Create the trigger
CREATE TRIGGER handle_new_user_trigger
  BEFORE INSERT OR UPDATE ON accounts
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Update constraints with better error messages
ALTER TABLE accounts DROP CONSTRAINT IF EXISTS username_length;
ALTER TABLE accounts DROP CONSTRAINT IF EXISTS email_valid;

ALTER TABLE accounts 
  ADD CONSTRAINT username_length 
  CHECK (char_length(username) >= 3) 
  NOT VALID;

ALTER TABLE accounts 
  ADD CONSTRAINT email_valid 
  CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') 
  NOT VALID;

-- Validate existing data
ALTER TABLE accounts VALIDATE CONSTRAINT username_length;
ALTER TABLE accounts VALIDATE CONSTRAINT email_valid;