--Calling the stored python procedure load_kaggle_set to 
--populate schema with data from Kaggle user gregorut's dataset videogamesales
USE SCHEMA {{db_name}}.{{schema_name}};
--We are also performing an sum on column global_sales by columns platform and year
CALL load_kaggle_dataset('gregorut', 'videogamesales', {'cat': ['"Platform"', '"Year"'], 'agg': {'"Global_Sales"':'sum'}});
