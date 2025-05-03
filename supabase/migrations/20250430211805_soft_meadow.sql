/*
  # Clean database data

  This migration removes all data while preserving table structures and policies.

  1. Actions
    - Truncate all tables in the correct order to handle foreign key constraints
    - Clean auth schema data
    - Reset all sequences
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