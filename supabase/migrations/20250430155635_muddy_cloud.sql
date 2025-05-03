/*
  # Fix Chat RLS Policies

  1. Changes
    - Drop existing RLS policies for chats table
    - Create new, properly configured RLS policies
    
  2. Security
    - Ensures users can only:
      - Insert chats where they are the profile_id
      - Read chats they are part of
      - Update their own chats
      - Delete their own chats
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON chats;
DROP POLICY IF EXISTS "Enable read access for chat participants" ON chats;
DROP POLICY IF EXISTS "Users can delete own chats" ON chats;
DROP POLICY IF EXISTS "Users can update own chats" ON chats;

-- Recreate policies with correct conditions
CREATE POLICY "Enable insert for authenticated users only" 
ON chats FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = profile_id);

CREATE POLICY "Enable read access for chat participants" 
ON chats FOR SELECT 
TO authenticated 
USING (auth.uid() = profile_id);

CREATE POLICY "Users can update own chats" 
ON chats FOR UPDATE 
TO authenticated 
USING (auth.uid() = profile_id)
WITH CHECK (auth.uid() = profile_id);

CREATE POLICY "Users can delete own chats" 
ON chats FOR DELETE 
TO authenticated 
USING (auth.uid() = profile_id);