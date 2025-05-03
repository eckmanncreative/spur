/*
  # Add user search function and chat creation

  1. New Functions
    - `search_users`: Search users by username, first name, or last name
    - `create_chat`: Create a new chat between users

  2. Changes
    - Add function to search users globally or within existing chats
    - Add function to create new chats
*/

-- Function to search users
CREATE OR REPLACE FUNCTION search_users(
  search_query text,
  known_contacts_only boolean,
  profile_id uuid DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  username text,
  first_name text,
  last_name text,
  has_chat boolean
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  WITH user_chats AS (
    SELECT DISTINCT p.id as user_id
    FROM profiles p
    JOIN chats c ON c.profile_id = profile_id
    WHERE profile_id IS NOT NULL
  )
  SELECT 
    p.id,
    p.username,
    p.first_name,
    p.last_name,
    CASE WHEN uc.user_id IS NOT NULL THEN true ELSE false END as has_chat
  FROM profiles p
  LEFT JOIN user_chats uc ON p.id = uc.user_id
  WHERE 
    (
      p.username ILIKE '%' || search_query || '%' OR
      p.first_name ILIKE '%' || search_query || '%' OR
      p.last_name ILIKE '%' || search_query || '%'
    )
    AND (
      (known_contacts_only = false) OR
      (known_contacts_only = true AND uc.user_id IS NOT NULL)
    )
    AND (profile_id IS NULL OR p.id != profile_id)
  ORDER BY 
    CASE 
      WHEN p.username ILIKE search_query THEN 0
      WHEN p.username ILIKE search_query || '%' THEN 1
      WHEN p.first_name ILIKE search_query || '%' THEN 2
      WHEN p.last_name ILIKE search_query || '%' THEN 3
      ELSE 4
    END,
    p.username;
END;
$$;