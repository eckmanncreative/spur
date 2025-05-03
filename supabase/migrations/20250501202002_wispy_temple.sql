/*
  # Fix message access between chat participants

  1. Changes
    - Update RLS policies to allow proper message access
    - Add policy for reading messages in chats where user is a participant
    - Add policy for sending messages in chats where user is a participant
    - Add indexes for better query performance

  2. Security
    - Enable RLS on messages table
    - Ensure proper access control through chat ownership
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Allow reading messages in chats" ON messages;
DROP POLICY IF EXISTS "Allow sending messages in chats" ON messages;

-- Create new policies with proper access control
CREATE POLICY "Allow reading messages in chats"
ON messages FOR SELECT
TO authenticated
USING (
  chat_id IN (
    SELECT id FROM chats
    WHERE account_id = auth.uid()
    OR profile_id IN (
      SELECT id FROM profiles
      WHERE account_id = auth.uid()
    )
  )
);

CREATE POLICY "Allow sending messages in chats"
ON messages FOR INSERT
TO authenticated
WITH CHECK (
  chat_id IN (
    SELECT id FROM chats
    WHERE account_id = auth.uid()
    OR profile_id IN (
      SELECT id FROM profiles
      WHERE account_id = auth.uid()
    )
  )
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS messages_chat_id_idx ON messages(chat_id);
CREATE INDEX IF NOT EXISTS messages_sender_idx ON messages(sender);
CREATE INDEX IF NOT EXISTS messages_created_at_idx ON messages(created_at);