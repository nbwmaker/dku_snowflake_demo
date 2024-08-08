-- Creating the base database, schema, and warehouse environment if they do not already exist
CREATE DATABASE IF NOT EXISTS {{db_name}};
CREATE SCHEMA IF NOT EXISTS {{db_name}}.{{schema_name}};
USE SCHEMA {{db_name}}.{{schema_name}};

CREATE WAREHOUSE IF NOT EXISTS XSMALL_WH
    WITH WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

USE WAREHOUSE XSMALL_WH;