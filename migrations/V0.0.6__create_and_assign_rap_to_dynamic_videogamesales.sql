USE SCHEMA DKU_DEMO.{{schema_name}};

--Creating and adding a row access policy for dynamic_videogamesales
CREATE OR REPLACE ROW ACCESS POLICY videogame_company_restriction
AS (platform varchar) RETURNS BOOLEAN ->
    CASE
        WHEN 'ACCOUNTADMIN' = CURRENT_ROLE() THEN TRUE
        WHEN platform IN ('3DS', 'DS', 'GB', 'GBA', 'N64', 'NES', 'SNES', 'Wii', 'WiiU') THEN is_role_in_session('nintendo')
        WHEN platform IN ('PS', 'PS2', 'PS3', 'PS4', 'PSV', 'PSP') THEN is_role_in_session('sony')
        WHEN platform IN ('PC', 'XB', 'X360', 'XOne') THEN is_role_in_session('microsoft')
        ELSE FALSE
    END
;

ALTER TABLE dynamic_videogamesales ADD ROW ACCESS POLICY videogame_company_restriction ON (platform);