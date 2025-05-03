/*
  # Fix search_users function ORDER BY issue

  1. Changes
    - Drop existing search_users function
    - Create new search_users function with corrected SELECT and ORDER BY clauses
    - Include all ORDER BY expressions in the SELECT list for DISTINCT compatibility

  2. Security
    - Maintain existing security context (SECURITY DEFINER)
    - Function accessible to authenticated users only
*/

-- Drop the existing function
DROP FUNCTION IF EXISTS search_users;

-- Create new function with fixed SELECT and ORDER BY
CREATE OR REPLACE FUNCTION search_users(
  search_query TEXT,
  known_contacts_only BOOLEAN,
  user_profile_id UUID
)
RETURNS TABLE (
  id UUID,
  username TEXT,
  first_name TEXT,
  last_name TEXT,
  full_name TEXT,
  created_at TIMESTAMPTZ
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT
    p.id,
    p.username,
    p.first_name,
    p.last_name,
    p.first_name || ' ' || COALESCE(p.last_name, '') as full_name,
    p.created_at
  FROM profiles p
  WHERE 
    (
      p.username ILIKE '%' || search_query || '%' OR
      p.first_name ILIKE '%' || search_query || '%' OR
      p.last_name ILIKE '%' || search_query || '%' OR
      (p.first_name || ' ' || COALESCE(p.last_name, '')) ILIKE '%' || search_query || '%'
    )
    AND p.id != user_profile_id
    AND (
      NOT known_contacts_only 
      OR 
      EXISTS (
        SELECT 1 FROM chats c 
        WHERE c.profile_id = user_profile_id
      )
    )
  ORDER BY 
    p.first_name,
    p.last_name,
    p.username,
    p.created_at;
END;
$$;