-- Creating a role for Flask API setup with read access to Kaggle data schema
USE ROLE ACCOUNTADMIN;
USE DATABASE CENTRAL_DB;
CREATE OR REPLACE ROLE DATA_API_ROLE;
GRANT USAGE ON WAREHOUSE XSMALL_WH TO ROLE DATA_API_ROLE;
GRANT USAGE ON DATABASE {{db_name}} TO ROLE DATA_API_ROLE;
GRANT USAGE ON SCHEMA {{db_name}}.{{schema_name}} TO ROLE DATA_API_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA {{db_name}}.{{schema_name}} TO ROLE DATA_API_ROLE;
GRANT ROLE DATA_API_ROLE TO ROLE ACCOUNTADMIN;

-- Creating database for image registry
CREATE OR REPLACE DATABASE API;
GRANT ALL ON DATABASE API TO ROLE DATA_API_ROLE;
GRANT ALL ON SCHEMA API.PUBLIC TO ROLE DATA_API_ROLE;

-- Creating image registry
USE DATABASE API;
CREATE OR REPLACE IMAGE REPOSITORY API;
GRANT READ ON IMAGE REPOSITORY API TO ROLE DATA_API_ROLE;

-- Show Image repositories to retrieve repository url
SHOW IMAGE REPOSITORIES;
SHOW IMAGES IN IMAGE REPOSITORY API;

-- Create compute pool
USE ROLE ACCOUNTADMIN;

CREATE COMPUTE POOL API
  MIN_NODES = 1
  MAX_NODES = 5
  INSTANCE_FAMILY = CPU_X64_XS;
-- DESCRIBE COMPUTE POOL API;

GRANT USAGE ON COMPUTE POOL API TO ROLE DATA_API_ROLE;
GRANT MONITOR ON COMPUTE POOL API TO ROLE DATA_API_ROLE;

-- Create application service
GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE DATA_API_ROLE;

USE ROLE DATA_API_ROLE;
CREATE SERVICE API.PUBLIC.{{sf_database}}_API
 IN COMPUTE POOL API
 FROM SPECIFICATION  
$$
spec:
  container:
  - name: api
    image: /api/public/api/{{sf_database}}_dataapi:latest
    env:
        SNOWFLAKE_ACCOUNT: {{sf_account}}
        SNOWFLAKE_USER: {{sf_user}}
        SNOWFLAKE_PASSWORD: {{sf_password}}
        SNOWFLAKE_WAREHOUSE: {{sf_warehouse}}
        SNOWFLAKE_DATABASE: {{db_name}}
        SNOWFLAKE_SCHEMA: {{schema_name}}
    resources:                          
      requests:
        cpu: 0.5
        memory: 128M
      limits:
        cpu: 1
        memory: 256M
  endpoint:
  - name: api
    port: 8001
    public: true
$$
QUERY_WAREHOUSE = {{sf_warehouse}};

-- Check status of service
CALL SYSTEM$GET_SERVICE_STATUS('api');
CALL SYSTEM$GET_SERVICE_LOGS('api.public.api', 0, 'api');

-- Show endpoints to get ingress_url
SHOW ENDPOINTS IN SERVICE API;
