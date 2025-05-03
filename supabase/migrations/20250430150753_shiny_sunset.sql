/*
  # Create initial user profile

  1. Changes
    - Insert a new profile for user1
    
  2. Notes
    - Creates a profile with username 'user1' and name 'brian'
    - Uses a fixed UUID for reproducibility
*/

INSERT INTO profiles (id, username, first_name, last_name, name)
VALUES (
  'e52c52ce-077b-4ebb-8fd8-777c3b6b3f61',  -- Fixed UUID for the profile
  'user1',                                  -- username
  'brian',                                  -- first_name
  NULL,                                     -- last_name
  'brian'                                   -- name
)
ON CONFLICT (username) DO NOTHING;         -- Prevent duplicate usernames