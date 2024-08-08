USE ROLE DATA_API_ROLE;
USE DATABASE API;
CREATE SERVICE API.PUBLIC.API
 IN COMPUTE POOL API
 FROM SPECIFICATION  
$$
spec:
  container:
  - name: api
    image: /api/public/api/dataapi:latest
    env:
        SNOWFLAKE_ACCOUNT: {{sf_account}}
        SNOWFLAKE_USER: {{sf_user}}
        SNOWFLAKE_PASSWORD: {{snowflake_password}}
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