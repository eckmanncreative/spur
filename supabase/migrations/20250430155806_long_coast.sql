/*
  # Fix Chats RLS Policy

  1. Changes
    - Update the INSERT policy for chats table to allow authenticated users to create chats
    - The policy now allows users to create chats where they are the profile_id

  2. Security
    - Maintains RLS enabled on chats table
    - Updates policy to properly handle chat creation
    - Ensures users can only create chats for their own profile
*/

DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON chats;

CREATE POLICY "Enable insert for authenticated users only"
ON chats
FOR INSERT
TO authenticated
WITH CHECK (
  profile_id = auth.uid()
);