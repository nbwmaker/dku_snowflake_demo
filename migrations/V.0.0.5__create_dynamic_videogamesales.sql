--creating a dynamic table on the videogamesales dataset we created with load_kaggle_dataset
USE SCHEMA DKU_DEMO.{{schema_name}};
CREATE OR REPLACE DYNAMIC TABLE dynamic_videogamesales
    LAG='DOWNSTREAM' 
    WAREHOUSE=XSMALL_WH
AS
SELECT 
    a."Platform" as platform,
    LISTAGG(a."Year", ', ') WITHIN GROUP (ORDER BY a."Year" ASC) as years_active,
    SUM(a."SUM(GLOBAL_SALES)") as global_sales
FROM kaggle_test.videogamesales a
GROUP BY a."Platform";