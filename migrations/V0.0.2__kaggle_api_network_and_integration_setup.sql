-- Establish network and integration dependencies to allow Kaggle API access.
USE SCHEMA {{db_name}}.{{schema_name}};
CREATE OR REPLACE NETWORK RULE kaggle_api_network_rule
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = ('www.kaggle.com', 'storage.googleapis.com');

-- the public.kaggle_central_auth SECRET is manually created in the public schema to avoid committing credentials to repo
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION kaggle_api_access_integration
    ALLOWED_NETWORK_RULES = (kaggle_api_network_rule)
    ALLOWED_AUTHENTICATION_SECRETS = (central_db.public.kaggle_central_auth)
    ENABLED = TRUE;