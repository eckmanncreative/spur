/*
  # Fix search_users function

  1. Changes
    - Drop existing function
    - Create new function with correct return type and ordering
    - Add proper search functionality for users
    
  2. Security
    - Maintain SECURITY DEFINER
    - Set search_path to public
*/

-- First drop the existing function
DROP FUNCTION IF EXISTS search_users(text, boolean, uuid);

-- Create new function with fixed return type and ordering
CREATE OR REPLACE FUNCTION search_users(
  search_query TEXT,
  known_contacts_only BOOLEAN,
  user_profile_id UUID
)
RETURNS TABLE (
  id UUID,
  username TEXT,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ,
  relevance INTEGER
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    a.username,
    a.display_name,
    a.avatar_url,
    a.created_at,
    CASE 
      WHEN a.username ILIKE search_query THEN 0
      WHEN a.username ILIKE search_query || '%' THEN 1
      WHEN a.display_name ILIKE search_query THEN 2
      WHEN a.display_name ILIKE search_query || '%' THEN 3
      ELSE 4
    END AS relevance
  FROM accounts a
  WHERE 
    a.id != user_profile_id
    AND (
      a.username ILIKE '%' || search_query || '%'
      OR a.display_name ILIKE '%' || search_query || '%'
    )
    AND (
      NOT known_contacts_only 
      OR EXISTS (
        SELECT 1 
        FROM chats c 
        WHERE c.account_id = user_profile_id 
        AND c.profile_id = a.id
      )
    )
  ORDER BY 
    relevance,
    a.created_at DESC;
END;
$$;