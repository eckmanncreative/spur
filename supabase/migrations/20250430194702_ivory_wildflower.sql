/*
  # Fix messages RLS policies with simplified access control

  1. Changes
    - Drop existing message policies
    - Create new simplified policies that properly check ownership
    - Add policy for authenticated users to insert messages
    - Add policy for authenticated users to read messages
    
  2. Security
    - Enable RLS
    - Ensure proper access control through profile ownership
*/

-- First ensure RLS is enabled
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to start fresh
DROP POLICY IF EXISTS "Enable read access for users chat messages" ON messages;
DROP POLICY IF EXISTS "Enable insert access for users chat messages" ON messages;
DROP POLICY IF EXISTS "Enable update access for users chat messages" ON messages;
DROP POLICY IF EXISTS "Enable delete access for users chat messages" ON messages;

-- Create simplified policies
CREATE POLICY "Allow users to read messages in their chats"
ON messages FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.account_id = auth.uid()
    AND profiles.id IN (
      SELECT chats.profile_id
      FROM chats
      WHERE chats.id = messages.chat_id
    )
  )
);

CREATE POLICY "Allow users to insert messages in their chats"
ON messages FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.account_id = auth.uid()
    AND profiles.id IN (
      SELECT chats.profile_id
      FROM chats
      WHERE chats.id = chat_id
    )
  )
);