/*
  # Fix Chat RLS Policies

  1. Changes
    - Drop existing INSERT policy and create a new one with correct authentication check
    - Update SELECT policy to ensure proper access control
  
  2. Security
    - Ensures users can only create chats where they are the profile_id
    - Maintains existing read access controls
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Users can create their own chats" ON chats;
DROP POLICY IF EXISTS "Users can read their own chats" ON chats;

-- Create new INSERT policy
CREATE POLICY "Enable insert for authenticated users only" 
ON public.chats
FOR INSERT 
TO authenticated
WITH CHECK (
  auth.uid() = profile_id
);

-- Create new SELECT policy
CREATE POLICY "Enable read access for chat participants" 
ON public.chats
FOR SELECT 
TO authenticated
USING (
  profile_id = auth.uid()
);