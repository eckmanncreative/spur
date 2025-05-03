/*
  # Create profiles table with improved reliability

  1. New Tables
    - `profiles`
      - `id` (uuid, primary key)
      - `username` (text, unique, min length 3)
      - `first_name` (text)
      - `last_name` (text, optional)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
      - `password` (text)

  2. Indexes
    - B-tree indexes for exact matches on username, first_name, last_name
    - Trigram indexes for fuzzy search on full name and username

  3. Security
    - Enable RLS
    - Policies for public search and authenticated access
*/

-- Create the profiles table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text NOT NULL,
  first_name text NOT NULL,
  last_name text,
  password text NOT NULL DEFAULT 'password',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT username_length CHECK (char_length(username) >= 3)
);

-- Add unique constraint for username
DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'profiles_username_key'
  ) THEN
    ALTER TABLE public.profiles ADD CONSTRAINT profiles_username_key UNIQUE (username);
  END IF;
END $$;

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create indexes one at a time with existence checks
DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'profiles_username_idx'
  ) THEN
    CREATE INDEX profiles_username_idx ON public.profiles USING btree (username);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'profiles_firstname_idx'
  ) THEN
    CREATE INDEX profiles_firstname_idx ON public.profiles USING btree (first_name);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'profiles_lastname_idx'
  ) THEN
    CREATE INDEX profiles_lastname_idx ON public.profiles USING btree (last_name);
  END IF;
END $$;

-- Create trigram indexes with existence checks
DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'profiles_name_trgm_idx'
  ) THEN
    CREATE INDEX profiles_name_trgm_idx ON public.profiles 
    USING gin ((first_name || ' ' || COALESCE(last_name, '')) gin_trgm_ops);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'profiles_username_trgm_idx'
  ) THEN
    CREATE INDEX profiles_username_trgm_idx ON public.profiles 
    USING gin (username gin_trgm_ops);
  END IF;
END $$;

-- Create RLS policies with existence checks
DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE policyname = 'Allow public username search'
  ) THEN
    CREATE POLICY "Allow public username search" 
    ON public.profiles
    FOR SELECT 
    TO public 
    USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE policyname = 'Allow authenticated to read profiles'
  ) THEN
    CREATE POLICY "Allow authenticated to read profiles" 
    ON public.profiles
    FOR SELECT 
    TO authenticated 
    USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE policyname = 'Users can read their own profiles'
  ) THEN
    CREATE POLICY "Users can read their own profiles" 
    ON public.profiles
    FOR SELECT 
    TO authenticated 
    USING (auth.uid() = id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE policyname = 'Users can update own profile'
  ) THEN
    CREATE POLICY "Users can update own profile" 
    ON public.profiles
    FOR UPDATE 
    TO authenticated 
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE policyname = 'Users can update their own password'
  ) THEN
    CREATE POLICY "Users can update their own password" 
    ON public.profiles
    FOR UPDATE 
    TO authenticated 
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);
  END IF;
END $$;