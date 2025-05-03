/*
  # Add password field to profiles

  1. Changes
    - Add password column to profiles table
    - Add function to set default password
    - Add policy to allow users to update their own password
*/

-- Add password column with default value 'password'
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS password text NOT NULL DEFAULT 'password';

-- Create function to hash passwords
CREATE OR REPLACE FUNCTION hash_password(password text)
RETURNS text
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN crypt(password, gen_salt('bf'));
END;
$$;

-- Update existing passwords to be hashed
UPDATE profiles 
SET password = hash_password('password')
WHERE password = 'password';

-- Add policy to allow users to update their own password
CREATE POLICY "Users can update their own password"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);