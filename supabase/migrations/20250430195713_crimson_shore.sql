/*
  # Sync initial chat data
  
  1. Data Changes
    - Insert initial chat records with proper UUID casting
    - Insert corresponding messages for each chat
    - Update chat metadata with latest message information
*/

-- First, insert the chats
INSERT INTO chats (id, profile_id, name, avatar_url, created_at)
SELECT 
  uuid::uuid,
  (SELECT id FROM profiles LIMIT 1), -- Gets the first profile as default
  name,
  avatar_url,
  created_at
FROM (VALUES
  ('123e4567-e89b-12d3-a456-426614174000'::uuid, 'Emma Johnson', '/ellipse-1.png', NOW() - INTERVAL '3 DAYS'),
  ('223e4567-e89b-12d3-a456-426614174001'::uuid, 'Anonymous', '/ellipse-2.png', NOW() - INTERVAL '3 DAYS'),
  ('323e4567-e89b-12d3-a456-426614174002'::uuid, 'Olivia Davis', '/ellipse-3.png', NOW() - INTERVAL '3 DAYS'),
  ('423e4567-e89b-12d3-a456-426614174003'::uuid, 'Noah Brown', '/ellipse-4.png', NOW() - INTERVAL '3 DAYS'),
  ('523e4567-e89b-12d3-a456-426614174004'::uuid, 'Ava Miller', '/ellipse-5.png', NOW() - INTERVAL '3 DAYS'),
  ('623e4567-e89b-12d3-a456-426614174005'::uuid, 'James Wilson', '/ellipse-6.png', NOW() - INTERVAL '3 DAYS'),
  ('723e4567-e89b-12d3-a456-426614174006'::uuid, 'Sophia Garcia', '/ellipse-7.png', NOW() - INTERVAL '3 DAYS'),
  ('823e4567-e89b-12d3-a456-426614174007'::uuid, 'Lucas Anderson', '/ellipse-8.png', NOW() - INTERVAL '3 DAYS')
) AS t(uuid, name, avatar_url, created_at);

-- Then insert the messages
INSERT INTO messages (chat_id, sender, content, created_at)
VALUES
  ('123e4567-e89b-12d3-a456-426614174000'::uuid, 'user', 'Could you provide details about your cleaning services availability?', NOW() - INTERVAL '2 HOURS'),
  ('123e4567-e89b-12d3-a456-426614174000'::uuid, 'coach', 'Our cleaning services are available Monday through Saturday, 8 AM to 6 PM. We offer both regular scheduling and one-time deep cleaning services.', NOW() - INTERVAL '1 HOUR 55 MINUTES'),
  
  ('223e4567-e89b-12d3-a456-426614174001'::uuid, 'user', 'I''d like to know more about your catering packages for events.', NOW() - INTERVAL '3 HOURS'),
  ('223e4567-e89b-12d3-a456-426614174001'::uuid, 'coach', 'We offer various catering packages ranging from intimate gatherings to large corporate events. Would you like me to break down the different options?', NOW() - INTERVAL '2 HOURS 55 MINUTES'),
  
  ('323e4567-e89b-12d3-a456-426614174002'::uuid, 'user', 'Are there any discounts currently offered on your fitness classes?', NOW() - INTERVAL '1 DAY'),
  ('323e4567-e89b-12d3-a456-426614174002'::uuid, 'coach', 'Yes! We''re currently running a summer special - 20% off on all class packages when you sign up for 3 months or more.', NOW() - INTERVAL '23 HOURS'),
  ('323e4567-e89b-12d3-a456-426614174002'::uuid, 'user', 'That sounds great! What types of classes are included?', NOW() - INTERVAL '22 HOURS'),
  
  ('423e4567-e89b-12d3-a456-426614174003'::uuid, 'user', 'What financing options do you offer for home renovations?', NOW() - INTERVAL '1 DAY'),
  ('423e4567-e89b-12d3-a456-426614174003'::uuid, 'coach', 'We partner with several financing providers offering flexible payment plans. Terms range from 12-60 months with competitive rates.', NOW() - INTERVAL '23 HOURS'),
  
  ('523e4567-e89b-12d3-a456-426614174004'::uuid, 'user', 'Could you explain the process for booking a consultation session?', NOW() - INTERVAL '2 DAYS'),
  ('523e4567-e89b-12d3-a456-426614174004'::uuid, 'coach', 'Of course! The first step is scheduling a 30-minute discovery call where we discuss your goals and determine the best approach.', NOW() - INTERVAL '47 HOURS'),
  
  ('623e4567-e89b-12d3-a456-426614174005'::uuid, 'user', 'Is there a warranty included with your repair services?', NOW() - INTERVAL '3 DAYS'),
  ('623e4567-e89b-12d3-a456-426614174005'::uuid, 'coach', 'Yes, all our repair services come with a 90-day warranty covering both parts and labor.', NOW() - INTERVAL '71 HOURS'),
  
  ('723e4567-e89b-12d3-a456-426614174006'::uuid, 'user', 'How soon can I schedule an appointment for pet grooming?', NOW() - INTERVAL '7 DAYS'),
  ('723e4567-e89b-12d3-a456-426614174006'::uuid, 'coach', 'We usually have availability within 2-3 days. For urgent requests, we also offer priority booking for an additional fee.', NOW() - INTERVAL '167 HOURS'),
  
  ('823e4567-e89b-12d3-a456-426614174007'::uuid, 'user', 'Do you offer refunds if things don''t along with furniture delivery?', NOW() - INTERVAL '14 DAYS'),
  ('823e4567-e89b-12d3-a456-426614174007'::uuid, 'coach', 'Yes, we have a satisfaction guarantee. If you''re not happy with the delivery service, we offer full refunds within 48 hours.', NOW() - INTERVAL '335 HOURS');

-- Update chats with last message information
UPDATE chats c
SET 
  last_message = m.content,
  last_message_at = m.created_at
FROM (
  SELECT DISTINCT ON (chat_id)
    chat_id,
    content,
    created_at
  FROM messages
  ORDER BY chat_id, created_at DESC
) m
WHERE c.id = m.chat_id;