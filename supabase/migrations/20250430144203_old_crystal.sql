/*
  # Fix Messages RLS Policies

  1. Changes
    - Update RLS policies for messages table to allow proper access
    - Add policies for inserting and reading messages
    - Link policies to chat ownership

  2. Security
    - Enable RLS on messages table
    - Add policies for authenticated users to:
      - Insert messages in chats they own
      - Read messages from chats they own
*/

-- First ensure RLS is enabled
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to recreate them
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'messages' 
    AND schemaname = 'public'
  ) THEN
    DROP POLICY IF EXISTS "Users can insert messages in their chats" ON messages;
    DROP POLICY IF EXISTS "Users can read messages in their chats" ON messages;
    DROP POLICY IF EXISTS "Users can update their own messages" ON messages;
  END IF;
END $$;

-- Create new policies
CREATE POLICY "Enable read access for chat participants"
ON messages FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM chats
    WHERE chats.id = messages.chat_id
    AND chats.profile_id = auth.uid()
  )
);

CREATE POLICY "Enable insert access for chat participants"
ON messages FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM chats
    WHERE chats.id = messages.chat_id
    AND chats.profile_id = auth.uid()
  )
);