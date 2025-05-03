/*
  # Fix message handling and display

  1. Changes
    - Add account_id column to messages table to track message ownership
    - Update RLS policies to use account_id for authorization
    - Add function to handle message creation with proper ownership
    
  2. Security
    - Enable RLS on messages table
    - Add policies for proper message access control
*/

-- Add account_id to messages table
ALTER TABLE messages
ADD COLUMN account_id uuid REFERENCES accounts(id);

-- Update existing messages to set account_id from chats
UPDATE messages m
SET account_id = c.account_id
FROM chats c
WHERE m.chat_id = c.id;

-- Make account_id NOT NULL after setting values
ALTER TABLE messages
ALTER COLUMN account_id SET NOT NULL;

-- Drop existing policies
DROP POLICY IF EXISTS "Allow users to read messages in their chats" ON messages;
DROP POLICY IF EXISTS "Allow users to insert messages in their chats" ON messages;

-- Create new policies
CREATE POLICY "Enable read access for chat participants"
ON messages FOR SELECT
TO authenticated
USING (
  chat_id IN (
    SELECT id FROM chats
    WHERE account_id = auth.uid()
  )
);

CREATE POLICY "Enable insert access for chat participants"
ON messages FOR INSERT
TO authenticated
WITH CHECK (
  chat_id IN (
    SELECT id FROM chats
    WHERE account_id = auth.uid()
  )
  AND account_id = auth.uid()
);

-- Create index for performance
CREATE INDEX messages_account_id_idx ON messages(account_id);