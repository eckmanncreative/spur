/*
  # Link users with chats

  1. Changes
    - Add account_id column to chats table
    - Update RLS policies to use account_id for authorization
    - Add foreign key constraint to link chats with accounts

  2. Security
    - Update RLS policies to use account_id instead of profile_id
    - Ensure users can only access their own chats
*/

-- Add account_id to chats table
ALTER TABLE chats
ADD COLUMN account_id uuid REFERENCES accounts(id);

-- Update RLS policy for chats
DROP POLICY IF EXISTS "Users can manage own chats" ON chats;
CREATE POLICY "Users can manage own chats" ON chats
FOR ALL TO authenticated
USING (account_id = auth.uid())
WITH CHECK (account_id = auth.uid());

-- Update messages policy to use account_id
DROP POLICY IF EXISTS "Allow users to read messages in their chats" ON messages;
DROP POLICY IF EXISTS "Allow users to insert messages in their chats" ON messages;

CREATE POLICY "Allow users to read messages in their chats" ON messages
FOR SELECT TO authenticated
USING (chat_id IN (
  SELECT id FROM chats WHERE account_id = auth.uid()
));

CREATE POLICY "Allow users to insert messages in their chats" ON messages
FOR INSERT TO authenticated
WITH CHECK (chat_id IN (
  SELECT id FROM chats WHERE account_id = auth.uid()
));