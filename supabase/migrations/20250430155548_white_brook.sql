/*
  # Update chats table RLS policies

  1. Changes
    - Drop existing INSERT policy that was too restrictive
    - Add new INSERT policy allowing authenticated users to create chats
    - Add policy for users to update their own chats
    - Add policy for users to delete their own chats

  2. Security
    - Maintains existing SELECT policy
    - Ensures users can only modify their own chats
*/

-- Drop the existing INSERT policy
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON chats;

-- Create new INSERT policy
CREATE POLICY "Enable insert for authenticated users only" ON chats
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = profile_id);

-- Add UPDATE policy
CREATE POLICY "Users can update own chats" ON chats
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = profile_id)
  WITH CHECK (auth.uid() = profile_id);

-- Add DELETE policy
CREATE POLICY "Users can delete own chats" ON chats
  FOR DELETE
  TO authenticated
  USING (auth.uid() = profile_id);