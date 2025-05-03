/*
  # Fresh Database Start
  
  1. Changes
    - Drop all existing data and tables
    - Remove existing triggers and functions
    - Reset schema to clean state
    
  2. Security
    - Enable RLS on all tables
    - Add appropriate policies for authenticated users
*/

-- Drop existing tables (in correct order to handle foreign keys)
DROP TABLE IF EXISTS attachments CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS chats CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;

-- Drop existing functions
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS handle_username_update() CASCADE;

-- Create accounts table
CREATE TABLE accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  username text UNIQUE NOT NULL,
  first_name text NOT NULL,
  last_name text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT email_valid CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  CONSTRAINT username_length CHECK (char_length(username) >= 3)
);

-- Create profiles table
CREATE TABLE profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create chats table
CREATE TABLE chats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id uuid REFERENCES accounts(id),
  profile_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
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
  chat_id uuid NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender text NOT NULL,
  content text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create attachments table
CREATE TABLE attachments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id uuid NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  file_name text NOT NULL,
  file_type text NOT NULL,
  file_size integer NOT NULL,
  file_url text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX accounts_email_idx ON accounts(email);
CREATE INDEX accounts_username_idx ON accounts(username);
CREATE INDEX accounts_name_idx ON accounts(first_name, last_name);
CREATE INDEX profiles_account_id_idx ON profiles(account_id);
CREATE INDEX chats_profile_id_idx ON profiles(id);
CREATE INDEX chats_created_at_idx ON chats(created_at);
CREATE INDEX messages_chat_id_idx ON messages(chat_id);
CREATE INDEX attachments_message_id_idx ON attachments(message_id);

-- Enable RLS
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE attachments ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can read own account" ON accounts
  FOR SELECT TO authenticated
  USING (id = auth.uid());

CREATE POLICY "Users can update own account" ON accounts
  FOR UPDATE TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

CREATE POLICY "Anyone can view profiles" ON profiles
  FOR SELECT TO public
  USING (true);

CREATE POLICY "Users can manage own profiles" ON profiles
  FOR ALL TO authenticated
  USING (account_id = auth.uid())
  WITH CHECK (account_id = auth.uid());

CREATE POLICY "Users can manage own chats" ON chats
  FOR ALL TO authenticated
  USING (account_id = auth.uid())
  WITH CHECK (account_id = auth.uid());

CREATE POLICY "Allow users to read messages in their chats" ON messages
  FOR SELECT TO authenticated
  USING (chat_id IN (
    SELECT id FROM chats WHERE account_id = auth.uid()
  ));

CREATE POLICY "Allow users to insert messages in their chats" ON messages
  FOR INSERT TO authenticated
  WITH CHECK (chat_id IN (
    SELECT id FROM chats WHERE account_id = auth.uid()
  ));

CREATE POLICY "Users can manage attachments in their messages" ON attachments
  FOR ALL TO authenticated
  USING (
    message_id IN (
      SELECT messages.id FROM messages
      WHERE messages.chat_id IN (
        SELECT chats.id FROM chats
        WHERE chats.account_id = auth.uid()
      )
    )
  )
  WITH CHECK (
    message_id IN (
      SELECT messages.id FROM messages
      WHERE messages.chat_id IN (
        SELECT chats.id FROM chats
        WHERE chats.account_id = auth.uid()
      )
    )
  );

-- Create function to handle new user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO accounts (id, email, username, first_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'first_name', NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user registration
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();