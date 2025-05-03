/*
  # Add avatar field to accounts table

  1. Changes
    - Add avatar_url column to accounts table
    - Update existing accounts to have null avatar_url
    - Add index for avatar_url lookups
    
  2. Security
    - Maintains existing RLS policies
    - No changes to security model
*/

-- Add avatar_url column
ALTER TABLE accounts
ADD COLUMN IF NOT EXISTS avatar_url text;

-- Create index for avatar lookups
CREATE INDEX IF NOT EXISTS accounts_avatar_url_idx ON accounts USING btree (avatar_url);

-- Update existing accounts to have null avatar
UPDATE accounts SET avatar_url = NULL;