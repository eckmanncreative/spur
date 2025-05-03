/*
  # Fix user creation trigger

  1. Changes
    - Update existing handle_new_user() function with improved validation
    - Add NOT NULL constraints to required columns
    - Set default values for timestamps
    
  2. Security
    - Maintains existing RLS policies
    - Preserves trigger functionality for auth.users
*/

-- Update the existing function with better error handling
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Set default values for timestamps
  NEW.created_at := COALESCE(NEW.created_at, now());
  NEW.updated_at := now();

  -- Ensure first_name is not empty
  IF NEW.first_name IS NULL OR trim(NEW.first_name) = '' THEN
    NEW.first_name := NEW.username;
  END IF;

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
    AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
  ) THEN
    RAISE EXCEPTION 'Username already taken';
  END IF;

  -- Check for duplicate email
  IF EXISTS (
    SELECT 1 FROM accounts 
    WHERE email = NEW.email 
    AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
  ) THEN
    RAISE EXCEPTION 'Email already registered';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Update table constraints
ALTER TABLE accounts 
  ALTER COLUMN created_at SET DEFAULT now(),
  ALTER COLUMN updated_at SET DEFAULT now(),
  ALTER COLUMN first_name SET NOT NULL,
  ALTER COLUMN email SET NOT NULL,
  ALTER COLUMN username SET NOT NULL;