/*
  # Update Database Schema for Accounts

  1. Changes
    - Create accounts table
    - Add account relationship to existing profiles table
    - Set up RLS policies
    - Create test data

  2. Security
    - Enable RLS on accounts table
    - Add policies for account management
    - Update profile policies
*/

-- Create accounts table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.accounts (
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

-- Add account_id to profiles if it doesn't exist
DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' 
    AND column_name = 'account_id'
  ) THEN
    ALTER TABLE public.profiles 
    ADD COLUMN account_id uuid REFERENCES public.accounts(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Enable RLS on accounts
ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;

-- Create indexes if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'accounts_email_idx') THEN
    CREATE INDEX accounts_email_idx ON public.accounts USING btree (email);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'accounts_username_idx') THEN
    CREATE INDEX accounts_username_idx ON public.accounts USING btree (username);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'accounts_name_idx') THEN
    CREATE INDEX accounts_name_idx ON public.accounts USING btree (first_name, last_name);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'profiles_account_id_idx') THEN
    CREATE INDEX profiles_account_id_idx ON public.profiles USING btree (account_id);
  END IF;
END $$;

-- Create account policies
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public can create accounts') THEN
    CREATE POLICY "Public can create accounts" ON public.accounts
      FOR INSERT TO public
      WITH CHECK (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can read own account') THEN
    CREATE POLICY "Users can read own account" ON public.accounts
      FOR SELECT TO authenticated
      USING (auth.uid() = id);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can update own account') THEN
    CREATE POLICY "Users can update own account" ON public.accounts
      FOR UPDATE TO authenticated
      USING (auth.uid() = id)
      WITH CHECK (auth.uid() = id);
  END IF;
END $$;

-- Update profile policies
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can manage own profiles') THEN
    CREATE POLICY "Users can manage own profiles" ON public.profiles
      FOR ALL TO authenticated
      USING (account_id = auth.uid())
      WITH CHECK (account_id = auth.uid());
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Anyone can view profiles') THEN
    CREATE POLICY "Anyone can view profiles" ON public.profiles
      FOR SELECT TO public
      USING (true);
  END IF;
END $$;

-- Insert test account if it doesn't exist
INSERT INTO public.accounts (
  id,
  email,
  username,
  password,
  first_name,
  last_name
) 
SELECT 
  'e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d',
  'user1@example.com',
  'user1',
  'password',
  'brian',
  NULL
WHERE NOT EXISTS (
  SELECT 1 FROM public.accounts 
  WHERE id = 'e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d'
);

-- Update existing profiles to link with the test account
UPDATE public.profiles 
SET account_id = 'e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d'
WHERE name IN ('Creative Agency', 'Life Coaching', 'Stealth Startup', 'Personal')
  AND (account_id IS NULL OR account_id = 'e87529b4-f49b-4f8b-a0f3-0ce27afd0d2d');