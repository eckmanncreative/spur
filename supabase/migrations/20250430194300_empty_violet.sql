/*
  # Fix Messages RLS Policies

  1. Changes
    - Drop existing RLS policies for messages table
    - Create new policies with correct ownership checks
    - Ensure proper access control for authenticated users

  2. Security
    - Enable RLS on messages table
    - Add policies for:
      - Reading messages in owned chats
      - Inserting messages in owned chats
      - Updating messages in owned chats
      - Deleting messages in owned chats
*/

-- First ensure RLS is enabled
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Enable read access for users chat messages" ON messages;
DROP POLICY IF EXISTS "Enable insert access for users chat messages" ON messages;
DROP POLICY IF EXISTS "Enable update access for users chat messages" ON messages;
DROP POLICY IF EXISTS "Enable delete access for users chat messages" ON messages;
DROP POLICY IF EXISTS "Users can manage messages in their chats" ON messages;

-- Create new policies with simplified ownership checks
CREATE POLICY "Enable read access for users chat messages"
ON messages FOR SELECT
TO authenticated
USING (
  chat_id IN (
    SELECT id FROM chats
    WHERE profile_id IN (
      SELECT id FROM profiles
      WHERE account_id = auth.uid()
    )
  )
);

CREATE POLICY "Enable insert access for users chat messages"
ON messages FOR INSERT
TO authenticated
WITH CHECK (
  chat_id IN (
    SELECT id FROM chats
    WHERE profile_id IN (
      SELECT id FROM profiles
      WHERE account_id = auth.uid()
    )
  )
);

CREATE POLICY "Enable update access for users chat messages"
ON messages FOR UPDATE
TO authenticated
USING (
  chat_id IN (
    SELECT id FROM chats
    WHERE profile_id IN (
      SELECT id FROM profiles
      WHERE account_id = auth.uid()
    )
  )
);

CREATE POLICY "Enable delete access for users chat messages"
ON messages FOR DELETE
TO authenticated
USING (
  chat_id IN (
    SELECT id FROM chats
    WHERE profile_id IN (
      SELECT id FROM profiles
      WHERE account_id = auth.uid()
    )
  )
);