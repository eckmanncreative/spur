/*
  # Add insert policy for chats table

  1. Changes
    - Add RLS policy to allow authenticated users to create their own chats
    
  2. Security
    - Users can only create chats where they are the owner (profile_id matches their uid)
    - Maintains existing security model while adding necessary insert capabilities
*/

CREATE POLICY "Users can create their own chats"
ON public.chats
FOR INSERT
TO authenticated
WITH CHECK (
  profile_id = auth.uid()
);