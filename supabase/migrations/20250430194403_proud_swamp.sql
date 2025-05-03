/*
  # Add test accounts and update relationships

  1. Changes
    - Insert test accounts with generated UUIDs
    - Create general profiles for new accounts
    - Update chat relationships
    - Update message senders
    
  2. Security
    - Maintains existing RLS policies
    - Preserves data relationships
*/

-- Insert new accounts with generated UUIDs
INSERT INTO public.accounts (
  email,
  username,
  password,
  first_name,
  last_name
)
SELECT
  email,
  username,
  'password',
  first_name,
  last_name
FROM (
  VALUES 
    ('emma.johnson@example.com', 'emmajohnson', 'Emma', 'Johnson'),
    ('anonymous@example.com', 'anonymous', 'Anonymous', NULL),
    ('olivia.davis@example.com', 'oliviadavis', 'Olivia', 'Davis'),
    ('noah.brown@example.com', 'noahbrown', 'Noah', 'Brown'),
    ('ava.miller@example.com', 'avamiller', 'Ava', 'Miller'),
    ('james.wilson@example.com', 'jameswilson', 'James', 'Wilson'),
    ('sophia.garcia@example.com', 'sophiagarcia', 'Sophia', 'Garcia'),
    ('lucas.anderson@example.com', 'lucasanderson', 'Lucas', 'Anderson')
) AS new_accounts(email, username, first_name, last_name)
WHERE NOT EXISTS (
  SELECT 1 FROM public.accounts 
  WHERE accounts.email = new_accounts.email
);

-- Create "general" profile for each new account
INSERT INTO public.profiles (
  account_id,
  name
)
SELECT 
  id,
  'general'
FROM public.accounts a
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p 
  WHERE p.account_id = a.id AND p.name = 'general'
)
AND id != 'e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d';

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
WHERE EXISTS (
  SELECT 1 FROM public.chats c
  WHERE c.id = m.chat_id
  AND c.name IN (
    SELECT first_name || ' ' || COALESCE(last_name, '')
    FROM public.accounts
  )
);