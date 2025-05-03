/*
  # Add RLS policies for messages

  1. Security
    - Enable RLS on messages table
    - Add policy for authenticated users to insert their own messages
    - Add policy for authenticated users to read messages in their chats
*/

-- Enable RLS
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Policy for inserting messages
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
      WHERE auth.uid() = profiles.id
    )
  )
);

-- Policy for updating messages
CREATE POLICY "Users can update their own messages"
ON messages
FOR UPDATE
TO authenticated
USING (
  chat_id IN (
    SELECT chats.id
    FROM chats
    WHERE chats.profile_id IN (
      SELECT profiles.id
      FROM profiles
      WHERE auth.uid() = profiles.id
    )
  )
);