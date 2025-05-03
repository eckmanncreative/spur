/*
  # Fix Messages RLS Policies

  1. Changes
    - Drop existing RLS policies for messages table
    - Create new policies that properly handle chat ownership through profiles
    - Add policies for all CRUD operations
    
  2. Security
    - Enable RLS
    - Add policies for authenticated users to:
      - Insert messages in their chats
      - Read messages from their chats
      - Update messages in their chats
      - Delete messages from their chats
*/

-- First ensure RLS is enabled
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Enable read access for users chat messages" ON messages;
    DROP POLICY IF EXISTS "Enable insert access for users chat messages" ON messages;
    DROP POLICY IF EXISTS "Enable update access for users chat messages" ON messages;
    DROP POLICY IF EXISTS "Enable delete access for users chat messages" ON messages;
    DROP POLICY IF EXISTS "Users can manage messages in their chats" ON messages;
END $$;

-- Create new policies with correct ownership checks
CREATE POLICY "Enable read access for users chat messages"
ON messages FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM chats
        WHERE chats.id = messages.chat_id
        AND chats.profile_id IN (
            SELECT profiles.id
            FROM profiles
            WHERE profiles.account_id = auth.uid()
        )
    )
);

CREATE POLICY "Enable insert access for users chat messages"
ON messages FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM chats
        WHERE chats.id = messages.chat_id
        AND chats.profile_id IN (
            SELECT profiles.id
            FROM profiles
            WHERE profiles.account_id = auth.uid()
        )
    )
);

CREATE POLICY "Enable update access for users chat messages"
ON messages FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM chats
        WHERE chats.id = messages.chat_id
        AND chats.profile_id IN (
            SELECT profiles.id
            FROM profiles
            WHERE profiles.account_id = auth.uid()
        )
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM chats
        WHERE chats.id = messages.chat_id
        AND chats.profile_id IN (
            SELECT profiles.id
            FROM profiles
            WHERE profiles.account_id = auth.uid()
        )
    )
);

CREATE POLICY "Enable delete access for users chat messages"
ON messages FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM chats
        WHERE chats.id = messages.chat_id
        AND chats.profile_id IN (
            SELECT profiles.id
            FROM profiles
            WHERE profiles.account_id = auth.uid()
        )
    )
);