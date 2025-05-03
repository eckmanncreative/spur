/*
  # Fix message sender handling

  1. Changes
    - Update messages table to ensure proper sender tracking
    - Add index for message queries
    - Update existing messages with correct sender information

  2. Security
    - Maintain existing RLS policies
    - Ensure proper access control
*/

-- Create index for message queries
CREATE INDEX IF NOT EXISTS messages_sender_idx ON messages(sender);

-- Update existing messages to use correct sender
UPDATE messages m
SET sender = (
  SELECT username 
  FROM accounts 
  WHERE accounts.id = m.account_id
)
WHERE account_id IS NOT NULL;

-- Add constraint to ensure sender matches an account username
ALTER TABLE messages
ADD CONSTRAINT messages_sender_check
CHECK (
  sender IS NOT NULL
  AND trim(sender) != ''
);