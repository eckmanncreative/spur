/*
  # Fix message permissions for chat participants

  1. Changes
    - Update RLS policies to allow both chat owner and participant to read messages
    - Fix message sender handling to use account usernames
    - Add proper indexes for performance

  2. Security
    - Enable RLS on messages table
    - Add policies for proper message access
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Allow reading messages in chats" ON messages;
DROP POLICY IF EXISTS "Allow sending messages in chats" ON messages;

-- Create new policies with proper access control for both chat participants
CREATE POLICY "Allow reading messages in chats"
ON messages FOR SELECT
TO authenticated
USING (
  chat_id IN (
    SELECT c.id FROM chats c
    WHERE 
      -- Allow if user owns the chat
      c.account_id = auth.uid()
      -- Or if user is the chat participant
      OR c.profile_id IN (
        SELECT p.id FROM profiles p
        WHERE p.account_id = auth.uid()
      )
  )
);

CREATE POLICY "Allow sending messages in chats"
ON messages FOR INSERT
TO authenticated
WITH CHECK (
  chat_id IN (
    SELECT c.id FROM chats c
    WHERE 
      -- Allow if user owns the chat
      c.account_id = auth.uid()
      -- Or if user is the chat participant
      OR c.profile_id IN (
        SELECT p.id FROM profiles p
        WHERE p.account_id = auth.uid()
      )
  )
);

-- Ensure proper indexes exist
CREATE INDEX IF NOT EXISTS messages_chat_id_idx ON messages(chat_id);
CREATE INDEX IF NOT EXISTS messages_sender_idx ON messages(sender);
CREATE INDEX IF NOT EXISTS messages_account_id_idx ON messages(account_id);
CREATE INDEX IF NOT EXISTS messages_created_at_idx ON messages(created_at);

-- Update existing messages to use correct sender usernames
UPDATE messages m
SET sender = (
  SELECT username 
  FROM accounts 
  WHERE accounts.id = m.account_id
)
WHERE account_id IS NOT NULL;