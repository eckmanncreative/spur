/*
  # Update Messages Table RLS Policies

  1. Changes
    - Add INSERT policy for messages table to allow authenticated users to create messages in their chats
    
  2. Security
    - Maintains existing RLS policies
    - Adds new policy for INSERT operations
    - Ensures users can only create messages in chats they have access to
*/

CREATE POLICY "Users can insert messages in their chats"
ON messages
FOR INSERT
TO authenticated
WITH CHECK (
  chat_id IN (
    SELECT chats.id
    FROM chats
    WHERE chats.profile_id IN (
      SELECT profiles.id
      FROM profiles
      WHERE profiles.account_id = auth.uid()
    )
  )
);