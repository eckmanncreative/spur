/*
  # Update accounts table schema

  1. Changes
    - Make first_name column nullable
    - Remove first_name default value logic from trigger
    
  2. Security
    - Maintain existing RLS policies
    - Keep all other constraints
*/

-- Make first_name nullable
ALTER TABLE accounts ALTER COLUMN first_name DROP NOT NULL;

-- Update the trigger function to remove first_name default logic
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Set default values for timestamps
  NEW.created_at := COALESCE(NEW.created_at, now());
  NEW.updated_at := now();

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