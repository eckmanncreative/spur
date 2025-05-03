/*
  # Update RLS policies for chats table

  1. Changes
    - Update RLS policies for the chats table to allow authenticated users to:
      - Create new chats where they are the profile owner
      - Read chats where they are the profile owner
      - Update their own chats
      - Delete their own chats

  2. Security
    - Maintains RLS enabled on chats table
    - Updates policies to properly check profile ownership
    - Ensures users can only manage their own chats
*/

-- Drop existing policies to recreate them with correct conditions
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON chats;
DROP POLICY IF EXISTS "Enable read access for chat participants" ON chats;
DROP POLICY IF EXISTS "Users can delete own chats" ON chats;
DROP POLICY IF EXISTS "Users can update own chats" ON chats;

-- Create new policies with correct conditions
CREATE POLICY "Enable insert for authenticated users only"
ON chats
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = chats.profile_id
    AND profiles.id = auth.uid()
  )
);

CREATE POLICY "Enable read access for chat participants"
ON chats
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = chats.profile_id
    AND profiles.id = auth.uid()
  )
);

CREATE POLICY "Users can update own chats"
ON chats
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = chats.profile_id
    AND profiles.id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = chats.profile_id
    AND profiles.id = auth.uid()
  )
);

CREATE POLICY "Users can delete own chats"
ON chats
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = chats.profile_id
    AND profiles.id = auth.uid()
  )
);