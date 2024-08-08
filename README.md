# Data Engineer Technical Assessment

For this assessment, I have created Github Actions schemachange migration scripts to create and execute the following steps:

## Solution built
1. Create a Snowflake python stored procedure that accesses the external Kaggle API and
receives the [videogamesales](https://www.kaggle.com/datasets/gregorut/videogamesales) dataset back to Snowflake
    1. This python stored procedure performs an aggregation prior to loading to a Snowflake table
    2. Then loads the data to a Snowflake raw table `videogamesales`
2. Create a Dynamic Table `dynamic_videogamesales` in Snowflake and applies a SUM on GLOBAL_SALES and LISTAGG on YEAR for each PLATFORM to the raw table `videogamesales`
3. Create a Row Access Policy and apply a dynamic filter to the Dynamic Table tied to fictious ROLEs for Microsoft, Nintendo, and Sony. The Row Access Policy only allows these companies to view records for their own platforms. \(e.g. "microsoft" : \('PC', 'XB', 'X360', 'XOne'\)\)
4. Leveraging Github Acitons and schemachange, this all is deployed to the Snowflake account. The only requirements of the Snowflake environment is a database that contains the Kaggle authentication secret.
5. **Bonus!** Create a local API endpoint using a docker contained Flaskapp to read data from `videogamesales` in Snowflake and return it in the HTTP response via JSON format. The service in Snowflake also provides an endpoint of `<api-endpoint>/test` which provides a simple HTML tester for the API.

## Workflows
Steps 1-4 are achieved through the `dku_snowflake_devops_[stage]_deploy.yml` files. There is a dependency on a `CENTRAL_DB` and `CENTRAL_DB.PUBLIC.kaggle_central_auth` secret being created with Kaggle API's username and password. I have created three separate ones to mimic a dev, staging, and production environment. These monitor corresponding branches within the repository on the `migrations/**` path. They each pass a uniquely named `db_name` to schemachange, to go along with the `schema_name` dedicated to the Kaggle dataset we will be pulling into the schema with the API. This enables reuse of the versioned scripts within `migrations/**`. A unique table is also specified for schemachange's history table, so that they do not collide when determining the latest change applied. 

Step 5 is planned to be managed with `snowflake_flask_api_demo_dev_docker.yml`. 


## Dependencies
Environment setup that is currently a manual effort is contained within the `pre-work/**` directory.

The GitHub Actions require a number of secrets to be setup:
* SF_ACCOUNT - Snowflake account URL, in a format such as `ex99999.us-east-2.aws`
* SF_DATABASE - Snowflake database to use for deployment
* SF_WAREHOUSE - Snowflake warehouse to use for deployment
* SF_ROLE - Snowflake role to use for deployment, ACCOUNTADMIN was used for this demo
* SF_USERNAME - Snowflake user with privilege to use the provided Snowflake account, database, warehouse, and role
* SF_PASSWORD - Snowflake user's authentication

For expanding the deployment of the Flask API, an SF_IMG_REPO secret would be needed for directing the docker image push.

## To-Do/Optimize
* Improve least privilege / access management within the Snowflake instance.
* More flexible Kaggle API file retrieval (csv, zip, json)
* GitHub file staging
* CREATE SECRET via deployment and GitHub Action secret
* Row Access Policy mapping table instead of hardcoded mappings
* Deploy Flask API docker image to Snowflake via GitHub Actions
* Deploy latest docker image as Snowflake Service Endpoint via GitHub Actions

## Cleanup
I have provided the queries used for cleaning up all the various objects created throughout the other scripts in `utility/full_cleanup.sql`.

## References

Besides plenty of general use of [Snowflake's documentation](https://docs.snowflake.com/) overall, there are a few specific resources of QuickStart Guides or Tutorial docs which were particularly impactful. 

### GitHub Actions & schemachange
* [DevOps: Database Change Management with schemachange and GitHub](https://quickstarts.snowflake.com/guide/devops_dcm_schemachange_github/#0)

### Flask API
* [Build a Custom API in Python and Flask](https://quickstarts.snowflake.com/guide/build_a_custom_api_in_python/index.html?index=..%2F..index#0)
* [Tutorial 1: Create a Snowpark Container Services Service](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/tutorials/tutorial-1#create-a-service)