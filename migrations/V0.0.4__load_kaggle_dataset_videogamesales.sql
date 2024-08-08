-- Calling the stored python procedure load_kaggle_dataset to 
-- populate schema with data from Kaggle user gregorut's dataset videogamesales
USE SCHEMA {{db_name}}.{{schema_name}};
-- We are also performing an sum on column global_sales by columns platform and year
CALL load_kaggle_dataset('gregorut', 'videogamesales', {'cat': ['"Platform"', '"Year"'], 'agg': {'"Global_Sales"':'sum'}});

-- provide access to data_api_role for the data
GRANT USAGE ON DATABASE {{db_name}} TO ROLE DATA_API_ROLE;
GRANT USAGE ON SCHEMA {{db_name}}.{{schema_name}} TO ROLE DATA_API_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA {{db_name}}.{{schema_name}} TO ROLE DATA_API_ROLE;
