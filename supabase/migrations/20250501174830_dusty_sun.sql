/*
  # Fix search_users function

  1. Changes
    - Drop existing function to allow return type change
    - Recreate function with correct return type and parameters
    - Add proper ordering and filtering
    
  2. Security
    - Maintain SECURITY DEFINER setting
    - Keep existing access patterns
*/

-- First drop the existing function
DROP FUNCTION IF EXISTS search_users(text, boolean, uuid);

-- Recreate the function with the new return type
CREATE OR REPLACE FUNCTION public.search_users(
  search_query text,
  known_contacts_only boolean,
  user_profile_id uuid
)
RETURNS TABLE (
  id uuid,
  display_name text,
  username text,
  avatar_url text
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT ON (a.id)
    a.id,
    a.display_name,
    a.username,
    a.avatar_url
  FROM accounts a
  WHERE 
    a.id != user_profile_id
    AND (
      a.display_name ILIKE '%' || search_query || '%'
      OR a.username ILIKE '%' || search_query || '%'
    )
  ORDER BY 
    a.id,
    a.display_name,
    a.username;
END;
$$;