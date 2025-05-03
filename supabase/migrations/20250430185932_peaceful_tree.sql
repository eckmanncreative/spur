/*
  # Sync Initial Messages

  1. Changes
    - Create function to handle timestamp conversion
    - Insert initial messages for existing chats
    - Update chat metadata with last message info
*/

-- Function to convert relative time to timestamp
CREATE OR REPLACE FUNCTION relative_time_to_timestamp(relative_time text)
RETURNS timestamptz AS $$
DECLARE
  base_time timestamptz;
BEGIN
  base_time := CURRENT_TIMESTAMP;
  
  IF relative_time LIKE 'today%' THEN
    IF relative_time LIKE '%AM' OR relative_time LIKE '%PM' THEN
      RETURN date_trunc('day', base_time) + 
             to_timestamp(substring(relative_time from 7), 'HH:MI AM')::time;
    ELSE
      RETURN date_trunc('day', base_time) + interval '12 hours';
    END IF;
  ELSIF relative_time = 'yday' THEN
    RETURN date_trunc('day', base_time - interval '1 day') + interval '12 hours';
  ELSIF relative_time = '2d' THEN
    RETURN date_trunc('day', base_time - interval '2 days') + interval '12 hours';
  ELSIF relative_time = '3d' THEN
    RETURN date_trunc('day', base_time - interval '3 days') + interval '12 hours';
  ELSIF relative_time = '7d' THEN
    RETURN date_trunc('day', base_time - interval '7 days') + interval '12 hours';
  ELSIF relative_time = '2w' THEN
    RETURN date_trunc('day', base_time - interval '14 days') + interval '12 hours';
  ELSE
    RETURN base_time;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Insert messages for Emma Johnson's chat
WITH chat_data AS (
  SELECT c.id as chat_id, p.account_id
  FROM chats c
  JOIN profiles p ON c.profile_id = p.id
  WHERE c.name = 'Emma Johnson'
)
INSERT INTO messages (chat_id, sender, content, created_at)
VALUES
  (
    (SELECT chat_id FROM chat_data),
    (SELECT username FROM accounts WHERE first_name = 'Emma' AND last_name = 'Johnson'),
    'Could you provide details about your cleaning services availability?',
    relative_time_to_timestamp('today 10:35 AM')
  ),
  (
    (SELECT chat_id FROM chat_data),
    'user1',
    'Our cleaning services are available Monday through Saturday, 8 AM to 6 PM. We offer both regular scheduling and one-time deep cleaning services.',
    relative_time_to_timestamp('today 10:40 AM')
  );

-- Insert messages for Anonymous chat
WITH chat_data AS (
  SELECT c.id as chat_id, p.account_id
  FROM chats c
  JOIN profiles p ON c.profile_id = p.id
  WHERE c.name = 'Anonymous'
)
INSERT INTO messages (chat_id, sender, content, created_at)
VALUES
  (
    (SELECT chat_id FROM chat_data),
    'anonymous',
    'I''d like to know more about your catering packages for events.',
    relative_time_to_timestamp('today 9:15 AM')
  ),
  (
    (SELECT chat_id FROM chat_data),
    'user1',
    'We offer various catering packages ranging from intimate gatherings to large corporate events. Would you like me to break down the different options?',
    relative_time_to_timestamp('today 9:20 AM')
  );

-- Update chats with last message and timestamp
UPDATE chats c
SET 
  last_message = (
    SELECT content
    FROM messages m
    WHERE m.chat_id = c.id
    ORDER BY m.created_at DESC
    LIMIT 1
  ),
  last_message_at = (
    SELECT created_at
    FROM messages m
    WHERE m.chat_id = c.id
    ORDER BY m.created_at DESC
    LIMIT 1
  )
WHERE EXISTS (
  SELECT 1
  FROM messages m
  WHERE m.chat_id = c.id
);

-- Drop the helper function
DROP FUNCTION relative_time_to_timestamp(text);