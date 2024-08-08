-- creating a dynamic table on the videogamesales dataset we created with load_kaggle_dataset
-- the aggregation applied SUMs GLOBAL_SALES and LISTAGG the YEARs available by platform
-- this gives a lifespawn view of a platforms sale performance
USE SCHEMA {{db_name}}.{{schema_name}};
CREATE OR REPLACE DYNAMIC TABLE dynamic_videogamesales
    LAG='DOWNSTREAM' 
    WAREHOUSE=XSMALL_WH
AS
SELECT 
    a."Platform" as platform,
    LISTAGG(a."Year", ', ') WITHIN GROUP (ORDER BY a."Year" ASC) as years_active,
    SUM(a."SUM(GLOBAL_SALES)") as global_sales
FROM {{schema_name}}.videogamesales a
GROUP BY a."Platform";
