/*
  # Add user fields to profiles table

  1. Changes
    - Add username column (unique, required)
    - Add first_name column (required)
    - Add last_name column (optional)
    - Add search index for username and names
    - Update RLS policies

  2. Security
    - Enable RLS
    - Add policy for public username search
    - Add policy for authenticated users to read basic profile info
    - Add policy for users to update their own profiles
*/

-- Enable the pg_trgm extension for better text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Add new columns
ALTER TABLE profiles
ADD COLUMN username text NOT NULL UNIQUE,
ADD COLUMN first_name text NOT NULL,
ADD COLUMN last_name text;

-- Create btree indexes for exact matches
CREATE INDEX profiles_username_idx ON profiles USING btree (username);
CREATE INDEX profiles_firstname_idx ON profiles USING btree (first_name);
CREATE INDEX profiles_lastname_idx ON profiles USING btree (last_name);

-- Create trigram indexes for pattern matching
CREATE INDEX profiles_username_trgm_idx ON profiles USING gin (username gin_trgm_ops);
CREATE INDEX profiles_name_trgm_idx ON profiles USING gin (
  (first_name || ' ' || COALESCE(last_name, '')) gin_trgm_ops
);

-- Update RLS policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Allow public username search
CREATE POLICY "Allow public username search" ON profiles
FOR SELECT
TO public
USING (true);

-- Allow authenticated users to read basic profile info
CREATE POLICY "Allow authenticated to read profiles" ON profiles
FOR SELECT
TO authenticated
USING (true);

-- Allow users to update their own profiles
CREATE POLICY "Users can update own profile" ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Add function for username search
CREATE OR REPLACE FUNCTION search_profiles(search_query text)
RETURNS SETOF profiles
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT *
  FROM profiles
  WHERE 
    username ILIKE '%' || search_query || '%'
    OR first_name ILIKE '%' || search_query || '%'
    OR last_name ILIKE '%' || search_query || '%'
  ORDER BY 
    CASE 
      WHEN username ILIKE search_query THEN 0
      WHEN username ILIKE search_query || '%' THEN 1
      WHEN first_name ILIKE search_query || '%' THEN 2
      WHEN last_name ILIKE search_query || '%' THEN 3
      ELSE 4
    END,
    username;
$$;