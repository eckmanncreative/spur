/*
  # Migrate existing data to new schema

  1. Changes
    - Update existing chats to link with profiles
    - Update existing messages to maintain chat relationships
    - Update existing attachments to maintain message relationships

  2. Security
    - Maintains existing RLS policies
    - Preserves data relationships
*/

-- Update existing chats to link with correct profiles
UPDATE public.chats
SET profile_id = (
  SELECT id FROM profiles 
  WHERE profiles.account_id = 'e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d'
  AND profiles.name = chats.name
)
WHERE profile_id IS NULL;

-- Update existing messages to maintain relationships
UPDATE public.messages
SET sender = (
  SELECT username FROM accounts 
  WHERE id = 'e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d'
)
WHERE sender = 'coach';

-- Ensure all messages are linked to valid chats
DELETE FROM public.messages
WHERE chat_id NOT IN (SELECT id FROM public.chats);

-- Clean up orphaned attachments
DELETE FROM public.attachments
WHERE message_id NOT IN (SELECT id FROM public.messages);

-- Verify data integrity
DO $$ 
BEGIN
  -- Verify all chats have valid profile_ids
  IF EXISTS (
    SELECT 1 FROM public.chats 
    WHERE profile_id IS NULL 
    OR profile_id NOT IN (SELECT id FROM public.profiles)
  ) THEN
    RAISE EXCEPTION 'Data integrity check failed: Found chats with invalid profile_id';
  END IF;

  -- Verify all messages have valid chat_ids
  IF EXISTS (
    SELECT 1 FROM public.messages 
    WHERE chat_id IS NULL 
    OR chat_id NOT IN (SELECT id FROM public.chats)
  ) THEN
    RAISE EXCEPTION 'Data integrity check failed: Found messages with invalid chat_id';
  END IF;

  -- Verify all attachments have valid message_ids
  IF EXISTS (
    SELECT 1 FROM public.attachments 
    WHERE message_id IS NULL 
    OR message_id NOT IN (SELECT id FROM public.messages)
  ) THEN
    RAISE EXCEPTION 'Data integrity check failed: Found attachments with invalid message_id';
  END IF;
END $$;