-- creating a database for schemachange change history tables 
-- and the Kaggle authentication secret to be stored
CREATE DATABASE IF NOT EXISTS {{central_db_name}};

USE SCHEMA {{central_db_name}}.PUBLIC;

-- creating a centralized secret for each branch/database to leverage
CREATE SECRET kaggle_central_auth
    TYPE = PASSWORD
    USERNAME = {{kaggle_user}}
    PASSWORD = {{kaggle_token}};
