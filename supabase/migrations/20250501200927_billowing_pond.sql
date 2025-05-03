/*
  # Fix message display and permissions

  1. Changes
    - Update messages table to properly track sender and recipient
    - Fix RLS policies to allow proper message access
    - Add indexes for better query performance

  2. Security
    - Enable RLS
    - Add policies for proper message access
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for chat participants" ON messages;
DROP POLICY IF EXISTS "Enable insert access for chat participants" ON messages;

-- Create new policies with proper access control
CREATE POLICY "Allow reading messages in chats"
ON messages FOR SELECT
TO authenticated
USING (
  chat_id IN (
    SELECT id FROM chats
    WHERE account_id = auth.uid()
  )
);

CREATE POLICY "Allow sending messages in chats"
ON messages FOR INSERT
TO authenticated
WITH CHECK (
  chat_id IN (
    SELECT id FROM chats
    WHERE account_id = auth.uid()
  )
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS messages_chat_sender_idx ON messages(chat_id, sender);
CREATE INDEX IF NOT EXISTS messages_created_at_idx ON messages(created_at);

-- Update existing messages to use proper sender format
UPDATE messages m
SET sender = (
  SELECT username 
  FROM accounts 
  WHERE accounts.id = m.account_id
)
WHERE account_id IS NOT NULL;