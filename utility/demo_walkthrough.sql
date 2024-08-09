-- =========== ENV Selection ===========
USE ROLE ACCOUNTADMIN;

USE WAREHOUSE XSMALL_WH;

-- USE SCHEMA DKU_DEMO_DEV.KAGGLE_DATASETS;
-- USE SCHEMA DKU_DEMO_STAGING.KAGGLE_DATASETS;
USE SCHEMA DKU_DEMO_PROD.KAGGLE_DATASETS;

-- =========== STEP 1: Raw Data Table Populated by Kaggle API ===========
-- objects related to Kaggle API
SHOW SECRETS IN SCHEMA CENTRAL_DB.PUBLIC;
SHOW NETWORK RULES IN DATABASE DKU_DEMO_PROD;
SHOW INTEGRATIONS;
DESCRIBE PROCEDURE DKU_DEMO_PROD.KAGGLE_DATASETS.LOAD_KAGGLE_DATASET(VARCHAR, VARCHAR, OBJECT);

-- finally, view the table
SELECT * FROM KAGGLE_DATASETS.videogamesales limit 100;

-- =========== STEP 2: Dynamic Table ===========
-- checking if any Row Access Policies exist
SHOW ROW ACCESS POLICIES IN DATABASE DKU_DEMO_PROD;

-- show full dynamic table, as ACCOUNTADMIN always returns TRUE for Row Access Policy
USE ROLE ACCOUNTADMIN;
SELECT * FROM dynamic_videogamesales ORDER BY 1 ASC LIMIT 100;

-- =========== STEP 3: Row Access Policy ===========
-- demonstrating different results for roles as a result of Row Access Policy

-- nintendo is only allowed to see its platforms: ('3DS', 'DS', 'GB', 'GBA', 'N64', 'NES', 'SNES', 'Wii', 'WiiU')
USE ROLE nintendo;
SELECT * FROM dynamic_videogamesales ORDER BY 1 ASC LIMIT 100;

-- sony is only allowed to see its platforms: ('PS', 'PS2', 'PS3', 'PS4', 'PSV', 'PSP')
USE ROLE sony;
SELECT * FROM dynamic_videogamesales ORDER BY 1 ASC LIMIT 100;

-- microsoft is only allowed to see its platforms: ('PC', 'XB', 'X360', 'XOne')
USE ROLE microsoft;
SELECT * FROM dynamic_videogamesales ORDER BY 1 ASC LIMIT 100;

-- =========== BONUS: Flask API ===========
USE ROLE ACCOUNTADMIN;
USE DATABASE API;

-- show Image repositories to retrieve repository url
SHOW IMAGE REPOSITORIES;

-- check if any images are in the repository
SHOW IMAGES IN IMAGE REPOSITORY API;

-- swap to data_api_role to view API endpoint
USE ROLE DATA_API_ROLE;

-- view status of API service
SHOW SERVICES IN COMPUTE POOL API;

-- show endpoints to get ingress_url
SHOW ENDPOINTS IN SERVICE API;

-- =========== Cleanup ===========
-- swap back to ACCOUNTADMIN before cleaning up the environment to prevent a relog
USE ROLE ACCOUNTADMIN;