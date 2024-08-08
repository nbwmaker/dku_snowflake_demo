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

kaggle_user = os.getenv('KAGGLE_USER')
kaggle_token = os.getenv('KAGGLE_TOKEN')
sf_database = os.getenv('SF_DATABASE')
sf_warehouse = os.getenv('SF_WAREHOUSE')

conn = connect()

# Creating the central DB used for schemachange, warehouse, and Kaggle secret storage ======
conn.cursor().execute(f"CREATE DATABASE IF NOT EXISTS {sf_database}")
conn.cursor().execute(f"USE SCHEMA {sf_database}.PUBLIC")
conn.cursor().execute(f"CREATE WAREHOUSE IF NOT EXISTS {sf_warehouse} \
                      WITH WAREHOUSE_SIZE = 'XSMALL' \
                      AUTO_SUSPEND = 60 \
                      AUTO_RESUME = TRUE \
                      INITIALLY_SUSPENDED = TRUE")
conn.cursor().execute(f"CREATE SECRET kaggle_central_auth \
                      TYPE = PASSWORD \
                      USERNAME = \'{kaggle_user}\' \
                      PASSWORD = \'{kaggle_token}\'")

# Creating all dependencies for Flask API ===================================================
# conn.cursor().execute(f"")
# Creating a role for Flask API setup with read access to Kaggle data schema
conn.cursor().execute("USE ROLE ACCOUNTADMIN")
conn.cursor().execute(f"USE DATABASE {sf_database}")
conn.cursor().execute("CREATE OR REPLACE ROLE DATA_API_ROLE")
conn.cursor().execute(f"GRANT USAGE ON WAREHOUSE {sf_warehouse} TO ROLE DATA_API_ROLE")
conn.cursor().execute("GRANT ROLE DATA_API_ROLE TO ROLE ACCOUNTADMIN")

# Creating database for image registry
conn.cursor().execute("CREATE OR REPLACE DATABASE API")
conn.cursor().execute("GRANT ALL ON DATABASE API TO ROLE DATA_API_ROLE")
conn.cursor().execute("GRANT ALL ON SCHEMA API.PUBLIC TO ROLE DATA_API_ROLE")

# Creating image registry
conn.cursor().execute("USE DATABASE API")
conn.cursor().execute("CREATE OR REPLACE IMAGE REPOSITORY API")
conn.cursor().execute("GRANT READ ON IMAGE REPOSITORY API TO ROLE DATA_API_ROLE")

# Create compute pool
conn.cursor().execute("USE ROLE ACCOUNTADMIN")
conn.cursor().execute("CREATE COMPUTE POOL API \
                      MIN_NODES = 1 \
                      MAX_NODES = 5 \
                      INSTANCE_FAMILY = CPU_X64_XS")
conn.cursor().execute("GRANT USAGE ON COMPUTE POOL API TO ROLE DATA_API_ROLE")
conn.cursor().execute("GRANT MONITOR ON COMPUTE POOL API TO ROLE DATA_API_ROLE")

# Grant ability to create application service
conn.cursor().execute("GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE DATA_API_ROLE")








