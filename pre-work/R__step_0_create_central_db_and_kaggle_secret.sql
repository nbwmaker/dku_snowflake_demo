-- creating a database for schemachange change history tables 
-- and the Kaggle authentication secret to be stored
CREATE DATABASE IF NOT EXISTS CENTRAL_DB;

USE SCHEMA CENTRAL_DB.PUBLIC;

-- creating a centralized secret for each branch/database to leverage
CREATE SECRET kaggle_central_auth
    TYPE = PASSWORD
    USERNAME = '<YOUR_USERNAME_HERE>'
    PASSWORD = '<YOUR_PASSWORD_HERE>';
