-- Kaggle Databases ===================================================================
-- reset demo env
DROP DATABASE DKU_DEMO_DEV;
DROP TABLE CENTRAL_DB.SCHEMACHANGE.DEV_CHANGE_HISTORY;

-- reset staging env
DROP DATABASE DKU_DEMO_STAGING;
DROP TABLE CENTRAL_DB.SCHEMACHANGE.STAGING_CHANGE_HISTORY;

-- reset prod env
DROP DATABASE DKU_DEMO_PROD;
DROP TABLE CENTRAL_DB.SCHEMACHANGE.PROD_CHANGE_HISTORY;

-- Kaggle RAP Demo Roles ===================================================================
DROP ROLE kaggle_role;
DROP ROLE nintendo;
DROP ROLE sony;
DROP ROLE microsoft;

-- Flask API ===================================================================
-- stopping the API
USE ROLE DATA_API_ROLE;
ALTER SERVICE API.PUBLIC.API SUSPEND;

-- view status of API service
SHOW SERVICES IN COMPUTE POOL API;

-- dropping all objects related to the API
USE ACCOUNTADMIN;
DROP SERVICE API.PUBLIC.API;
DROP DATABASE IF EXISTS API;
DROP ROLE IF EXISTS DATA_API_ROLE;
DROP COMPUTE POOL IF EXISTS API;
DROP WAREHOUSE IF EXISTS DATA_API_WH;

-- Pre-work Databases ===================================================================
DROP DATABASE CENTRAL_DB;
DROP WAREHOUSE XSMALL_WH;