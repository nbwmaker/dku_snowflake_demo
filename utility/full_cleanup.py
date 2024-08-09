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
            'client_session_keep_alive': True
        }
    return snowflake.connector.connect(**creds)

sf_database = os.getenv('SF_DATABASE')
sf_warehouse = os.getenv('SF_WAREHOUSE')

conn = connect()

# ensure we are operating from ACCOUNTADMIN with privilege to all objects
conn.cursor().execute("USE ROLE ACCOUNTADMIN")

# Kaggle Databases ===================================================================
# reset demo env
conn.cursor().execute("DROP DATABASE IF EXISTS DKU_DEMO_DEV")
conn.cursor().execute(f"DROP TABLE IF EXISTS {sf_database}.SCHEMACHANGE.DEV_CHANGE_HISTORY")

# reset staging env
conn.cursor().execute("DROP DATABASE IF EXISTS DKU_DEMO_STAGING")
conn.cursor().execute(f"DROP TABLE IF EXISTS {sf_database}.SCHEMACHANGE.STAGING_CHANGE_HISTORY")

# reset prod env
conn.cursor().execute("DROP DATABASE IF EXISTS DKU_DEMO_PROD")
conn.cursor().execute(f"DROP TABLE IF EXISTS {sf_database}.SCHEMACHANGE.PROD_CHANGE_HISTORY")


# Kaggle RAP Demo Roles ===================================================================
conn.cursor().execute("DROP ROLE IF EXISTS kaggle_role")
conn.cursor().execute("DROP ROLE IF EXISTS nintendo")
conn.cursor().execute("DROP ROLE IF EXISTS sony")
conn.cursor().execute("DROP ROLE IF EXISTS microsoft")


# Flask API ===================================================================
# dropping all objects related to the API
conn.cursor().execute("DROP SERVICE IF EXISTS API.PUBLIC.API")
conn.cursor().execute("DROP DATABASE IF EXISTS API")
conn.cursor().execute("DROP ROLE IF EXISTS DATA_API_ROLE")
conn.cursor().execute("DROP COMPUTE POOL IF EXISTS API")

# Central resources ===================================================================
# dropping the base environment objects last
conn.cursor().execute(f"DROP DATABASE IF EXISTS {sf_database}")
conn.cursor().execute(f"DROP WAREHOUSE IF EXISTS {sf_warehouse}")
