/*
  # Fix messages RLS policies

  1. Changes
    - Drop all existing message policies
    - Create new simplified policies that properly handle chat ownership
    - Fix the relationship chain: auth.uid -> profiles -> chats -> messages

  2. Security
    - Enable RLS
    - Add policies for:
      - Reading messages in owned chats
      - Inserting messages in owned chats
*/

-- First ensure RLS is enabled
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to start fresh
DROP POLICY IF EXISTS "Allow users to read messages in their chats" ON messages;
DROP POLICY IF EXISTS "Allow users to insert messages in their chats" ON messages;
DROP POLICY IF EXISTS "Enable read access for users chat messages" ON messages;
DROP POLICY IF EXISTS "Enable insert access for users chat messages" ON messages;
DROP POLICY IF EXISTS "Enable update access for users chat messages" ON messages;
DROP POLICY IF EXISTS "Enable delete access for users chat messages" ON messages;
DROP POLICY IF EXISTS "Users can manage messages in their chats" ON messages;

-- Create new simplified policies
CREATE POLICY "Allow users to read messages in their chats"
ON messages FOR SELECT
TO authenticated
USING (
  chat_id IN (
    SELECT chats.id
    FROM chats
    JOIN profiles ON chats.profile_id = profiles.id
    WHERE profiles.account_id = auth.uid()
  )
);

CREATE POLICY "Allow users to insert messages in their chats"
ON messages FOR INSERT
TO authenticated
WITH CHECK (
  chat_id IN (
    SELECT chats.id
    FROM chats
    JOIN profiles ON chats.profile_id = profiles.id
    WHERE profiles.account_id = auth.uid()
  )
);