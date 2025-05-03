/*
  # Clean database for fresh start
  
  1. Changes
    - Truncate all application tables
    - Clean auth schema data
    - Reset sequences
*/

-- First clean auth schema data
TRUNCATE auth.users CASCADE;
TRUNCATE auth.refresh_tokens CASCADE;

-- Then clean application data
TRUNCATE attachments CASCADE;
TRUNCATE messages CASCADE;
TRUNCATE chats CASCADE;
TRUNCATE profiles CASCADE;
TRUNCATE accounts CASCADE;

-- Reset sequences
ALTER SEQUENCE IF EXISTS auth.users_id_seq RESTART;
ALTER SEQUENCE IF EXISTS auth.refresh_tokens_id_seq RESTART;
ALTER SEQUENCE IF EXISTS attachments_id_seq RESTART;
ALTER SEQUENCE IF EXISTS messages_id_seq RESTART;
ALTER SEQUENCE IF EXISTS chats_id_seq RESTART;
ALTER SEQUENCE IF EXISTS profiles_id_seq RESTART;
ALTER SEQUENCE IF EXISTS accounts_id_seq RESTART;