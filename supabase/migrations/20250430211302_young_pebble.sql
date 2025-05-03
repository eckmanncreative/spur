/*
  # Clean database and start fresh

  1. Changes
    - Drop all existing data from tables
    - Remove any existing triggers
    - Reset sequences
  
  2. Security
    - Maintain RLS policies
    - Keep table permissions intact
*/

-- Drop all data while preserving structure
TRUNCATE TABLE attachments CASCADE;
TRUNCATE TABLE messages CASCADE;
TRUNCATE TABLE chats CASCADE;
TRUNCATE TABLE profiles CASCADE;
TRUNCATE TABLE accounts CASCADE;

-- Reset sequences
ALTER SEQUENCE IF EXISTS attachments_id_seq RESTART;
ALTER SEQUENCE IF EXISTS messages_id_seq RESTART;
ALTER SEQUENCE IF EXISTS chats_id_seq RESTART;
ALTER SEQUENCE IF EXISTS profiles_id_seq RESTART;
ALTER SEQUENCE IF EXISTS accounts_id_seq RESTART;