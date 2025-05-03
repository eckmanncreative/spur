/*
  # Restructure Database Schema

  1. Changes
    - Drop existing tables to start fresh
    - Create accounts table with required fields
    - Create profiles table linked to accounts
    - Create chats table linked to profiles
    - Create messages table linked to chats
    - Create attachments table linked to messages
    
  2. Security
    - Enable RLS on all tables
    - Add appropriate policies for data access
*/

-- Drop existing tables in correct order
DROP TABLE IF EXISTS public.attachments CASCADE;
DROP TABLE IF EXISTS public.messages CASCADE;
DROP TABLE IF EXISTS public.chats CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.accounts CASCADE;

-- Create accounts table
CREATE TABLE public.accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  username text NOT NULL UNIQUE,
  password text NOT NULL,
  first_name text NOT NULL,
  last_name text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT username_length CHECK (char_length(username) >= 3),
  CONSTRAINT email_valid CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Create profiles table (linked to accounts)
CREATE TABLE public.profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create chats table (linked to profiles)
CREATE TABLE public.chats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name text NOT NULL,
  avatar_url text,
  last_message text,
  last_message_at timestamptz DEFAULT now(),
  unread boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create messages table (linked to chats)
CREATE TABLE public.messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id uuid NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  sender text NOT NULL,
  content text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create attachments table (linked to messages)
CREATE TABLE public.attachments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id uuid NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
  file_name text NOT NULL,
  file_type text NOT NULL,
  file_size integer NOT NULL,
  file_url text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS on all tables
ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attachments ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX accounts_email_idx ON public.accounts USING btree (email);
CREATE INDEX accounts_username_idx ON public.accounts USING btree (username);
CREATE INDEX accounts_name_idx ON public.accounts USING btree (first_name, last_name);
CREATE INDEX profiles_account_id_idx ON public.profiles USING btree (account_id);
CREATE INDEX chats_profile_id_idx ON public.chats USING btree (profile_id);
CREATE INDEX chats_created_at_idx ON public.chats USING btree (created_at);
CREATE INDEX messages_chat_id_idx ON public.messages USING btree (chat_id);
CREATE INDEX attachments_message_id_idx ON public.attachments USING btree (message_id);

-- Account policies
CREATE POLICY "Public can create accounts" ON public.accounts
  FOR INSERT TO public
  WITH CHECK (true);

CREATE POLICY "Users can read own account" ON public.accounts
  FOR SELECT TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own account" ON public.accounts
  FOR UPDATE TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Profile policies
CREATE POLICY "Users can manage own profiles" ON public.profiles
  FOR ALL TO authenticated
  USING (account_id = auth.uid())
  WITH CHECK (account_id = auth.uid());

CREATE POLICY "Anyone can view profiles" ON public.profiles
  FOR SELECT TO public
  USING (true);

-- Chat policies
CREATE POLICY "Users can manage own chats" ON public.chats
  FOR ALL TO authenticated
  USING (profile_id IN (
    SELECT id FROM profiles WHERE account_id = auth.uid()
  ))
  WITH CHECK (profile_id IN (
    SELECT id FROM profiles WHERE account_id = auth.uid()
  ));

-- Message policies
CREATE POLICY "Users can manage messages in their chats" ON public.messages
  FOR ALL TO authenticated
  USING (chat_id IN (
    SELECT id FROM chats WHERE profile_id IN (
      SELECT id FROM profiles WHERE account_id = auth.uid()
    )
  ))
  WITH CHECK (chat_id IN (
    SELECT id FROM chats WHERE profile_id IN (
      SELECT id FROM profiles WHERE account_id = auth.uid()
    )
  ));

-- Attachment policies
CREATE POLICY "Users can manage attachments in their messages" ON public.attachments
  FOR ALL TO authenticated
  USING (message_id IN (
    SELECT id FROM messages WHERE chat_id IN (
      SELECT id FROM chats WHERE profile_id IN (
        SELECT id FROM profiles WHERE account_id = auth.uid()
      )
    )
  ))
  WITH CHECK (message_id IN (
    SELECT id FROM messages WHERE chat_id IN (
      SELECT id FROM chats WHERE profile_id IN (
        SELECT id FROM profiles WHERE account_id = auth.uid()
      )
    )
  ));

-- Insert test account
INSERT INTO public.accounts (
  id,
  email,
  username,
  password,
  first_name,
  last_name
) VALUES (
  'e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d',
  'user1@example.com',
  'user1',
  'password',
  'brian',
  NULL
);

-- Create profiles for test account
INSERT INTO public.profiles (
  account_id,
  name
) VALUES 
  ('e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d', 'Creative Agency'),
  ('e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d', 'Life Coaching'),
  ('e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d', 'Stealth Startup'),
  ('e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d', 'Personal');

-- Insert sample chats for each profile
WITH profile_ids AS (
  SELECT id, name FROM profiles WHERE account_id = 'e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d'
)
INSERT INTO public.chats (
  id,
  profile_id,
  name,
  avatar_url,
  last_message,
  unread
)
SELECT
  uuid_generate_v4(),
  p.id,
  'Emma Johnson',
  '/ellipse-1.png',
  'Could you provide details about your cleaning services availability?',
  false
FROM profile_ids p
WHERE p.name = 'Life Coaching'
UNION ALL
SELECT
  uuid_generate_v4(),
  p.id,
  'Anonymous',
  '/ellipse-2.png',
  'I''d like to know more about your catering packages for events.',
  false
FROM profile_ids p
WHERE p.name = 'Life Coaching';