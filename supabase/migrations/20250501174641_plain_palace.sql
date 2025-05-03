/*
  # Update search_users function with improved user search

  1. Changes
    - Drop existing function to allow return type change
    - Create new function with updated return columns
    - Add avatar_url to returned fields
    - Improve search relevance ordering
    
  2. Security
    - Maintain SECURITY DEFINER
    - Keep existing access controls
*/

-- Drop the existing function first
DROP FUNCTION IF EXISTS search_users(text, boolean, uuid);

-- Create new function with updated return type
CREATE FUNCTION search_users(
  search_query TEXT,
  known_contacts_only BOOLEAN,
  user_profile_id UUID
)
RETURNS TABLE (
  id UUID,
  username TEXT,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT
    a.id,
    a.username,
    a.display_name,
    a.avatar_url,
    a.created_at
  FROM accounts a
  WHERE 
    -- Don't return the searching user
    a.id != user_profile_id
    -- Search by username or display name
    AND (
      a.username ILIKE '%' || search_query || '%'
      OR a.display_name ILIKE '%' || search_query || '%'
    )
    -- If known_contacts_only is true, only return users who have chatted with the current user
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
    -- Order by match relevance (exact matches first)
    CASE 
      WHEN a.username ILIKE search_query THEN 0
      WHEN a.display_name ILIKE search_query THEN 1
      ELSE 2
    END,
    -- Then by creation date (newest first)
    a.created_at DESC;
END;
$$;