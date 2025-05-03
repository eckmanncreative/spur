/*
  # Fix Messages RLS Policies

  1. Changes
    - Drop existing RLS policies for messages table
    - Create new, properly structured RLS policies that:
      - Allow users to insert messages in their chats
      - Allow users to read messages in their chats
      - Allow users to manage their own messages
  
  2. Security
    - Maintains data isolation between users
    - Ensures users can only access messages in chats they own
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Users can insert messages in their chats" ON messages;
DROP POLICY IF EXISTS "Users can manage messages in their chats" ON messages;

-- Create new policies
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
)
WITH CHECK (
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