/*
  # Add test user

  1. Changes
    - Insert a test user into the profiles table
    - Username: user1
    - Password: password
    - Name: User One
*/

INSERT INTO public.profiles (
  id,
  username,
  first_name,
  last_name,
  name,
  password
) VALUES (
  gen_random_uuid(),
  'user1',
  'User',
  'One',
  'User One',
  'password'
)
ON CONFLICT (username) DO NOTHING;