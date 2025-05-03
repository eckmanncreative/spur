/*
  # Update search_users function with new return type

  1. Changes
    - Drop existing search_users function
    - Create new search_users function with updated return columns
    - Add proper join with accounts table
    - Maintain existing search functionality
*/

-- First drop the existing function
DROP FUNCTION IF EXISTS search_users(text, boolean, uuid);

-- Create new function with updated return type
CREATE OR REPLACE FUNCTION public.search_users(
  search_query text,
  known_contacts_only boolean,
  user_profile_id uuid
)
RETURNS TABLE (
  profile_id uuid,
  profile_name text,
  username text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT
    p.id as profile_id,
    p.name as profile_name,
    a.username
  FROM profiles p
  JOIN accounts a ON p.account_id = a.id
  WHERE 
    (
      a.username ILIKE '%' || search_query || '%'
      OR p.name ILIKE '%' || search_query || '%'
    )
    AND (
      NOT known_contacts_only 
      OR EXISTS (
        SELECT 1 
        FROM chats c 
        WHERE c.profile_id = p.id 
        AND c.account_id = user_profile_id
      )
    )
    AND p.account_id != user_profile_id
  ORDER BY 
    CASE 
      WHEN a.username ILIKE search_query || '%' THEN 0
      WHEN p.name ILIKE search_query || '%' THEN 1
      ELSE 2
    END,
    a.username;
END;
$$;