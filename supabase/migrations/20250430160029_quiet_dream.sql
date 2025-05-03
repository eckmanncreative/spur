/*
  # Fresh start for chat policies
  
  1. Changes
    - Drop all existing policies
    - Re-enable RLS
    - Create simplified policies for all operations
    
  2. Security
    - Enable RLS on chats table
    - Add basic CRUD policies for authenticated users
*/

-- First, drop all existing policies
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON chats;
DROP POLICY IF EXISTS "Enable read access for chat participants" ON chats;
DROP POLICY IF EXISTS "Users can update own chats" ON chats;
DROP POLICY IF EXISTS "Users can delete own chats" ON chats;

-- Re-enable RLS
ALTER TABLE chats DISABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

-- Create fresh policies with simplified rules
CREATE POLICY "Enable insert for authenticated users only"
ON chats
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = profile_id);

CREATE POLICY "Enable read access for chat participants"
ON chats
FOR SELECT
TO authenticated
USING (auth.uid() = profile_id);

CREATE POLICY "Users can update own chats"
ON chats
FOR UPDATE
TO authenticated
USING (auth.uid() = profile_id)
WITH CHECK (auth.uid() = profile_id);

CREATE POLICY "Users can delete own chats"
ON chats
FOR DELETE
TO authenticated
USING (auth.uid() = profile_id);