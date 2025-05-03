/*
  # Update authentication to use username

  1. Changes
    - Add username column to auth.users table
    - Update accounts table to use username for authentication
    - Add trigger to sync username between auth.users and public.accounts
*/

-- Add username column to auth.users if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'auth' 
    AND table_name = 'users' 
    AND column_name = 'raw_user_meta_data'
  ) THEN
    ALTER TABLE auth.users ADD COLUMN raw_user_meta_data jsonb;
  END IF;
END $$;

-- Create function to handle username updates
CREATE OR REPLACE FUNCTION public.handle_username_update()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE auth.users
  SET raw_user_meta_data = jsonb_set(
    COALESCE(raw_user_meta_data, '{}'::jsonb),
    '{username}',
    to_jsonb(NEW.username)
  )
  WHERE id = NEW.id::uuid;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for username updates
DROP TRIGGER IF EXISTS on_username_update ON public.accounts;
CREATE TRIGGER on_username_update
  AFTER INSERT OR UPDATE OF username ON public.accounts
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_username_update();