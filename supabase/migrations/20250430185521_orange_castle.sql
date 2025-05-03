/*
  # Create Chat User Accounts

  1. Changes
    - Create accounts for each chat participant
    - Create "general" profile for each account
    - Update existing chats to link with new profiles
    - Update message senders to use account usernames

  2. Security
    - Uses proper UUID format
    - Maintains referential integrity
*/

-- Create accounts for chat users
INSERT INTO public.accounts (
  id,
  email,
  username,
  password,
  first_name,
  last_name
)
VALUES 
  (
    'a1b2c3d4-e5f6-4321-a123-426614174000',
    'emma.johnson@example.com',
    'emmajohnson',
    'password',
    'Emma',
    'Johnson'
  ),
  (
    'b2c3d4e5-f6a7-4321-b234-426614174001',
    'anonymous@example.com',
    'anonymous',
    'password',
    'Anonymous',
    NULL
  ),
  (
    'c3d4e5f6-a7b8-4321-c345-426614174002',
    'olivia.davis@example.com',
    'oliviadavis',
    'password',
    'Olivia',
    'Davis'
  ),
  (
    'd4e5f6a7-b8c9-4321-d456-426614174003',
    'noah.brown@example.com',
    'noahbrown',
    'password',
    'Noah',
    'Brown'
  ),
  (
    'e5f6a7b8-c9d0-4321-e567-426614174004',
    'ava.miller@example.com',
    'avamiller',
    'password',
    'Ava',
    'Miller'
  ),
  (
    'f6a7b8c9-d0e1-4321-f678-426614174005',
    'james.wilson@example.com',
    'jameswilson',
    'password',
    'James',
    'Wilson'
  ),
  (
    'a7b8c9d0-e1f2-4321-a789-426614174006',
    'sophia.garcia@example.com',
    'sophiagarcia',
    'password',
    'Sophia',
    'Garcia'
  ),
  (
    'b8c9d0e1-f2a3-4321-b890-426614174007',
    'lucas.anderson@example.com',
    'lucasanderson',
    'password',
    'Lucas',
    'Anderson'
  );

-- Create "general" profile for each account
INSERT INTO public.profiles (
  account_id,
  name
)
SELECT 
  id,
  'general'
FROM public.accounts
WHERE id != 'e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d';

-- Update existing chats to link with new profiles
UPDATE public.chats c
SET profile_id = (
  SELECT p.id 
  FROM public.profiles p
  JOIN public.accounts a ON p.account_id = a.id
  WHERE a.first_name || ' ' || COALESCE(a.last_name, '') = c.name
    AND p.name = 'general'
)
WHERE c.name IN (
  SELECT first_name || ' ' || COALESCE(last_name, '')
  FROM public.accounts
  WHERE id != 'e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d'
);

-- Update messages to use correct sender usernames
UPDATE public.messages m
SET sender = (
  SELECT a.username
  FROM public.accounts a
  WHERE a.first_name || ' ' || COALESCE(a.last_name, '') = (
    SELECT c.name
    FROM public.chats c
    WHERE c.id = m.chat_id
  )
)
WHERE sender = 'user';