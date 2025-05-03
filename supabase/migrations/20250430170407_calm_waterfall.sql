/*
  # Add email uniqueness constraint to auth.users table

  1. Changes
    - Adds a UNIQUE constraint on the email column of auth.users table
    - This ensures each email can only be used once for authentication
*/

ALTER TABLE auth.users ADD CONSTRAINT users_email_key UNIQUE (email);