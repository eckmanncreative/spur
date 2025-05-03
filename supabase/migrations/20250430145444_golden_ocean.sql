/*
  # Fix search_users function

  1. Changes
    - Drop existing search_users function
    - Recreate search_users function with:
      - Renamed profile_id parameter to user_profile_id
      - Fixed ambiguous column references
      - Improved search logic for contacts
*/

-- First drop the existing function
DROP FUNCTION IF EXISTS search_users(text, boolean, uuid);

-- Recreate the function with the correct signature and implementation
CREATE OR REPLACE FUNCTION search_users(
  search_query TEXT,
  known_contacts_only BOOLEAN,
  user_profile_id UUID
)
RETURNS SETOF profiles
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT p.*
  FROM profiles p
  WHERE 
    (
      p.username ILIKE '%' || search_query || '%'
      OR (p.first_name || ' ' || COALESCE(p.last_name, '')) ILIKE '%' || search_query || '%'
    )
    AND (
      NOT known_contacts_only 
      OR (
        known_contacts_only AND EXISTS (
          SELECT 1 FROM chats 
          WHERE chats.profile_id = user_profile_id
        )
      )
    )
    AND p.id != user_profile_id
  ORDER BY 
    CASE 
      WHEN p.username ILIKE search_query || '%' THEN 0
      WHEN p.username ILIKE '%' || search_query || '%' THEN 1
      ELSE 2
    END,
    p.username;
END;
$$;