-- Creating the base database and schema environment if they do not already exist
CREATE DATABASE IF NOT EXISTS {{db_name}};
CREATE SCHEMA IF NOT EXISTS {{db_name}}.{{schema_name}};
USE SCHEMA {{db_name}}.{{schema_name}};

-- Set warehouse usage
USE WAREHOUSE {{sf_warehouse}};
