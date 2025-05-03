/*
  # Update chats table RLS policies

  1. Changes
    - Drop existing INSERT policy
    - Create new INSERT policy with correct authentication check
    - Ensure authenticated users can only create chats where they are the owner

  2. Security
    - Maintains RLS enabled on chats table
    - Updates INSERT policy to properly check auth.uid()
*/

-- Drop the existing INSERT policy
DROP POLICY IF EXISTS "Users can create their own chats" ON chats;

-- Create new INSERT policy with correct auth check
CREATE POLICY "Users can create their own chats"
ON chats
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = profile_id);