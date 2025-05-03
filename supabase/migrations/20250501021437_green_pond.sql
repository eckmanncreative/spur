/*
  # Add username column to accounts table

  1. Changes
    - Add username column with a default value to handle existing rows
    - Add unique constraint for usernames
    - Add check constraint for minimum length
    - Create index for username lookups

  2. Notes
    - Uses display_name as default value for username to handle existing rows
    - Ensures all constraints are satisfied before making column NOT NULL
*/

-- First add the column as nullable
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS username text;

-- Set default values for existing rows using display_name
UPDATE accounts SET username = display_name WHERE username IS NULL;

-- Now make it NOT NULL since all rows have values
ALTER TABLE accounts ALTER COLUMN username SET NOT NULL;

-- Add constraints and index
ALTER TABLE accounts ADD CONSTRAINT accounts_username_key UNIQUE (username);
ALTER TABLE accounts ADD CONSTRAINT username_length CHECK (char_length(username) >= 3);
CREATE INDEX IF NOT EXISTS accounts_username_idx ON accounts USING btree (username);