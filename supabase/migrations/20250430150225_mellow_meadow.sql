/*
  # Update chat RLS policies

  1. Changes
    - Update RLS policies for the chats table to allow proper chat creation
    - Add policy for authenticated users to create chats where they are participants
    - Maintain existing policies for reading chats

  2. Security
    - Enable RLS on chats table (already enabled)
    - Update insert policy to allow authenticated users to create chats
    - Keep existing select policy for chat participants
*/

-- Drop the existing insert policy
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON chats;

-- Create new insert policy that properly checks profile ownership
CREATE POLICY "Enable insert for authenticated users only"
ON chats
FOR INSERT
TO authenticated
WITH CHECK (
  -- Allow insert if the user is authenticated and the profile_id matches their profile
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = chats.profile_id
    AND profiles.id = auth.uid()
  )
);

-- Keep the existing select policy
-- "Enable read access for chat participants" policy remains unchanged