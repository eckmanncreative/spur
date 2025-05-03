/*
  # Fix Auth Policies

  1. Changes
    - Add policy to allow Supabase service role to manage accounts
    - Add policy to allow auth service to create accounts
    - Update RLS policies to handle auth user creation

  2. Security
    - Maintains existing RLS protection
    - Adds specific policies for auth service
*/

-- Add policy for service role to manage accounts
CREATE POLICY "Service role can manage all accounts"
ON accounts
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Add policy to allow new account creation during signup
CREATE POLICY "Allow account creation during signup"
ON accounts
FOR INSERT
TO authenticated, anon
WITH CHECK (
  auth.uid() = id OR
  EXISTS (
    SELECT 1
    FROM auth.users
    WHERE auth.users.id = accounts.id
  )
);

-- Ensure RLS is enabled
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;