import os
import snowflake.connector

# Make Snowflake connection
def connect() -> snowflake.connector.SnowflakeConnection:
    if os.path.isfile("/snowflake/session/token"):
        creds = {
            'host': os.getenv('SNOWFLAKE_HOST'),
            'port': os.getenv('SNOWFLAKE_PORT'),
            'protocol': "https",
            'account': os.getenv('SNOWFLAKE_ACCOUNT'),
            'authenticator': "oauth",
            'token': open('/snowflake/session/token', 'r').read(),
            'warehouse': os.getenv('SNOWFLAKE_WAREHOUSE'),
            'database': os.getenv('SNOWFLAKE_DATABASE'),
            'schema': os.getenv('SNOWFLAKE_SCHEMA'),
            'client_session_keep_alive': True
        }
    else:
        creds = {
            'account': os.getenv('SF_ACCOUNT'),
            'user': os.getenv('SF_USERNAME'),
            'password': os.getenv('SNOWFLAKE_PASSWORD'),
            # 'warehouse': os.getenv('SNOWFLAKE_WAREHOUSE'),
            # 'database': os.getenv('SNOWFLAKE_DATABASE'),
            # 'schema': os.getenv('SNOWFLAKE_SCHEMA'),
            'client_session_keep_alive': True
        }
    return snowflake.connector.connect(**creds)

conn = connect()

-- conn.cursor().execute("")
conn.cursor().execute("USE ACCOUNTADMIN")

-- Kaggle Databases ===================================================================
-- reset demo env
-- DROP DATABASE IF EXISTS DKU_DEMO_DEV;
-- DROP TABLE IF EXISTS CENTRAL_DB.SCHEMACHANGE.DEV_CHANGE_HISTORY;

conn.cursor().execute("DROP DATABASE IF EXISTS DKU_DEMO_DEV")
conn.cursor().execute("DROP TABLE IF EXISTS CENTRAL_DB.SCHEMACHANGE.DEV_CHANGE_HISTORY")

-- reset staging env
-- DROP DATABASE IF EXISTS DKU_DEMO_STAGING;
-- DROP TABLE IF EXISTS CENTRAL_DB.SCHEMACHANGE.STAGING_CHANGE_HISTORY;

conn.cursor().execute("DROP DATABASE IF EXISTS DKU_DEMO_STAGING")
conn.cursor().execute("DROP TABLE IF EXISTS CENTRAL_DB.SCHEMACHANGE.STAGING_CHANGE_HISTORY")


-- reset prod env
-- DROP DATABASE IF EXISTS DKU_DEMO_PROD;
-- DROP TABLE IF EXISTS CENTRAL_DB.SCHEMACHANGE.PROD_CHANGE_HISTORY;

conn.cursor().execute("DROP DATABASE IF EXISTS DKU_DEMO_PROD")
conn.cursor().execute("DROP TABLE IF EXISTS CENTRAL_DB.SCHEMACHANGE.PROD_CHANGE_HISTORY")


-- Kaggle RAP Demo Roles ===================================================================
-- DROP ROLE IF EXISTS kaggle_role;
-- DROP ROLE IF EXISTS nintendo;
-- DROP ROLE IF EXISTS sony;
-- DROP ROLE IF EXISTS microsoft;

conn.cursor().execute("DROP ROLE IF EXISTS kaggle_role")
conn.cursor().execute("DROP ROLE IF EXISTS nintendo")
conn.cursor().execute("DROP ROLE IF EXISTS sony")
conn.cursor().execute("DROP ROLE IF EXISTS microsoft")


-- Flask API ===================================================================
-- stopping the API
-- USE ROLE DATA_API_ROLE;
-- ALTER SERVICE API.PUBLIC.API SUSPEND;

-- -- view status of API service
-- SHOW SERVICES IN COMPUTE POOL API;

-- dropping all objects related to the API
-- USE ACCOUNTADMIN;
-- DROP SERVICE IF EXISTS API.PUBLIC.API;
-- DROP DATABASE IF EXISTS API;
-- DROP ROLE IF EXISTS DATA_API_ROLE;
-- DROP COMPUTE POOL IF EXISTS API;
-- DROP WAREHOUSE IF EXISTS DATA_API_WH;

conn.cursor().execute("DROP SERVICE IF EXISTS API.PUBLIC.API")
conn.cursor().execute("DROP DATABASE IF EXISTS API")
conn.cursor().execute("DROP ROLE IF EXISTS DATA_API_ROLE")
conn.cursor().execute("DROP COMPUTE POOL IF EXISTS API")

-- Central resources ===================================================================
-- DROP DATABASE IF EXISTS CENTRAL_DB;
-- DROP WAREHOUSE IF EXISTS XSMALL_WH;

conn.cursor().execute("DROP DATABASE IF EXISTS CENTRAL_DB")
conn.cursor().execute("DROP WAREHOUSE IF EXISTS XSMALL_WH")
