/*
  # Clean all data from database

  This migration removes all data from both auth and application tables while preserving the structure.
  No new users or data will be created - this is just a clean slate.

  1. Changes
    - Truncates all auth-related tables
    - Truncates all application tables
    - Resets all sequences to start fresh
*/

-- First clean auth schema data
TRUNCATE auth.users CASCADE;
TRUNCATE auth.refresh_tokens CASCADE;
TRUNCATE auth.mfa_factors CASCADE;
TRUNCATE auth.mfa_challenges CASCADE;
TRUNCATE auth.mfa_amr_claims CASCADE;
TRUNCATE auth.flow_state CASCADE;
TRUNCATE auth.sso_providers CASCADE;
TRUNCATE auth.saml_providers CASCADE;
TRUNCATE auth.saml_relay_states CASCADE;
TRUNCATE auth.sessions CASCADE;

-- Then clean application data
TRUNCATE attachments CASCADE;
TRUNCATE messages CASCADE;
TRUNCATE chats CASCADE;
TRUNCATE profiles CASCADE;
TRUNCATE accounts CASCADE;

-- Reset sequences
ALTER SEQUENCE IF EXISTS auth.users_id_seq RESTART;
ALTER SEQUENCE IF EXISTS auth.refresh_tokens_id_seq RESTART;
ALTER SEQUENCE IF EXISTS auth.mfa_factors_id_seq RESTART;
ALTER SEQUENCE IF EXISTS auth.mfa_challenges_id_seq RESTART;
ALTER SEQUENCE IF EXISTS auth.flow_state_id_seq RESTART;
ALTER SEQUENCE IF EXISTS auth.sso_providers_id_seq RESTART;
ALTER SEQUENCE IF EXISTS auth.saml_providers_id_seq RESTART;
ALTER SEQUENCE IF EXISTS auth.saml_relay_states_id_seq RESTART;
ALTER SEQUENCE IF EXISTS auth.sessions_id_seq RESTART;
ALTER SEQUENCE IF EXISTS attachments_id_seq RESTART;
ALTER SEQUENCE IF EXISTS messages_id_seq RESTART;
ALTER SEQUENCE IF EXISTS chats_id_seq RESTART;
ALTER SEQUENCE IF EXISTS profiles_id_seq RESTART;
ALTER SEQUENCE IF EXISTS accounts_id_seq RESTART;