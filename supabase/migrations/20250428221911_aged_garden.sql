/*
  # Initial Schema Setup

  1. New Tables
    - `profiles`
      - `id` (uuid, primary key)
      - `name` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
      
    - `chats`
      - `id` (uuid, primary key)
      - `profile_id` (uuid, foreign key)
      - `name` (text)
      - `avatar_url` (text)
      - `last_message` (text)
      - `last_message_at` (timestamp)
      - `unread` (boolean)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `messages`
      - `id` (uuid, primary key)
      - `chat_id` (uuid, foreign key)
      - `sender` (text)
      - `content` (text)
      - `created_at` (timestamp)

    - `attachments`
      - `id` (uuid, primary key)
      - `message_id` (uuid, foreign key)
      - `file_name` (text)
      - `file_type` (text)
      - `file_size` (integer)
      - `file_url` (text)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Create profiles table
CREATE TABLE profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create chats table
CREATE TABLE chats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  name text NOT NULL,
  avatar_url text,
  last_message text,
  last_message_at timestamptz DEFAULT now(),
  unread boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create messages table
CREATE TABLE messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id uuid REFERENCES chats(id) ON DELETE CASCADE,
  sender text NOT NULL,
  content text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create attachments table
CREATE TABLE attachments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id uuid REFERENCES messages(id) ON DELETE CASCADE,
  file_name text NOT NULL,
  file_type text NOT NULL,
  file_size integer NOT NULL,
  file_url text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE attachments ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can read their own profiles"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can read their own chats"
  ON chats
  FOR SELECT
  TO authenticated
  USING (profile_id IN (
    SELECT id FROM profiles WHERE auth.uid() = profiles.id
  ));

CREATE POLICY "Users can read messages in their chats"
  ON messages
  FOR SELECT
  TO authenticated
  USING (chat_id IN (
    SELECT id FROM chats WHERE profile_id IN (
      SELECT id FROM profiles WHERE auth.uid() = profiles.id
    )
  ));

CREATE POLICY "Users can read attachments in their messages"
  ON attachments
  FOR SELECT
  TO authenticated
  USING (message_id IN (
    SELECT id FROM messages WHERE chat_id IN (
      SELECT id FROM chats WHERE profile_id IN (
        SELECT id FROM profiles WHERE auth.uid() = profiles.id
      )
    )
  ));