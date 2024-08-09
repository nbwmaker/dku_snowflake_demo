-- creating roles relating to row access policy for dynamic_videogamesales
-- granting necessary access to the role, then granting the role to primary user
CREATE ROLE IF NOT EXISTS kaggle_role;
GRANT USAGE ON DATABASE {{db_name}} TO ROLE kaggle_role;
GRANT USAGE ON WAREHOUSE {{sf_warehouse}} TO ROLE kaggle_role;
GRANT USAGE ON SCHEMA {{db_name}}.{{schema_name}} TO ROLE kaggle_role;
GRANT SELECT ON ALL TABLES IN SCHEMA {{db_name}}.{{schema_name}} TO ROLE kaggle_role;
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA {{db_name}}.{{schema_name}} TO ROLE kaggle_role;

-- Creating a role for nintendo, sony, and microsoft to demonstrate row access policy
-- again, granting these to primary use for demonstration purposes
CREATE ROLE IF NOT EXISTS nintendo;
GRANT ROLE kaggle_role TO ROLE nintendo;
GRANT ROLE nintendo TO USER {{sf_username}};

CREATE ROLE IF NOT EXISTS sony;
GRANT ROLE kaggle_role TO ROLE sony;
GRANT ROLE sony TO USER {{sf_username}};

CREATE ROLE IF NOT EXISTS microsoft;
GRANT ROLE kaggle_role TO ROLE microsoft;
GRANT ROLE microsoft TO USER {{sf_username}};
