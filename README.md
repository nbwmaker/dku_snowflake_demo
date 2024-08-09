# Data Engineer Technical Assessment
Demonstrating Snowflake, GitHub Actions, SQL, and python capabilities.

## Solution built
1. Create a Snowflake python stored procedure that accesses the external Kaggle API and
receives the [videogamesales](https://www.kaggle.com/datasets/gregorut/videogamesales) dataset back to Snowflake
    1. This python stored procedure performs a sum aggregation prior to loading to a Snowflake table to adjust the context from an individual video game title to a platform level.
    2. Then loads the data to a Snowflake raw table `videogamesales`
2. Create a Dynamic Table `dynamic_videogamesales` in Snowflake and applies a SUM on GLOBAL_SALES and LISTAGG on YEAR for each PLATFORM to the raw table `videogamesales`
3. Create a Row Access Policy and apply a dynamic filter to the Dynamic Table tied to fictious ROLEs for Microsoft, Nintendo, and Sony. The Row Access Policy only allows these companies to view records for their own platforms. \(e.g. "microsoft" : \('PC', 'XB', 'X360', 'XOne'\)\)
4. Leveraging Github Acitons and schemachange, this all is deployed to the Snowflake account.
5. **Bonus!** Create a local API endpoint using a docker contained Flaskapp to read data from `videogamesales` in Snowflake and return it in the HTTP response via JSON format. The service in Snowflake also provides an endpoint of `<api-endpoint>/test` which provides a simple HTML tester for the API.


## Base Environment Pre-Work
Before we can execute schemachange for steps 1-4, we need to create a database to house the schemachange history tables. We'll also establish a warehouse for use in all of the schemachange scripts. In addition to this, we'll create a database and image repository to house our API. This enables us to be able to build and push our Flask API image to our Snowflake account.

This is all handled via GitHub Action workflow `base_env_setup` which executes `base_setup/create_base_env.py`. 

_This workflow should take less than a minute to execute._


## Workflows
__Steps 1-4 are achieved through the `devops_snowflake_deploy` GitHub Action workflow.__
This action monitors repository branches `dev`, `staging`, and `main` within the `migrations/**` path. The workflow checks to see which branch is executing and determines which values to pass for target database name, target schema name, and target schemachange history table name. This enables reuse of the versioned scripts within `migrations/**`.

_This workflow should take less than two minutes to execute._

__Step 5 is managed with `build_and_deploy_flask_docker_img` GitHub Action workflow.__
This action builds the Flask app contained within `src/**` leveraging the `Dockerfile` in the root of the repository. The image is then pushed to the Snowflake image repository that was built during the `base_env_setup` workflow. After the image push is completed, the workflow uses schemachange to apply `utility/A__bind_latest_flask_api.sql` against our Snowflake account, which binds a local service endpoint for the API. 

_This workflow takes about seven minutes to execute._


## Dependencies
The GitHub Actions require a number of secrets to be set up:
* `SF_ACCOUNT` - Snowflake account URL, in a format such as `ex99999.us-east-2.aws`
* `SF_DATABASE` - Snowflake database to use for deployment
* `SF_WAREHOUSE` - Snowflake warehouse to use for deployment
* `SF_ROLE` - Snowflake role to use for deployment, ACCOUNTADMIN was used for this demo
* `SF_USERNAME` - Snowflake user with privilege to use the provided Snowflake account, database, warehouse, and role
* `SF_PASSWORD` - Snowflake user's authentication
* `SF_KAGGLE_USERNAME` - Kaggle username for which you have API access
* `SF_KAGGLE_TOKEN` - Kaggle API access token to pair with the Kaggle user
* `SF_IMG_REPO` - A URL Endpoint for Snowflake's image repository. This is created in the scripts, but is deterministic so it can be provided beforehand if you know the naming of the objects where it will live.


## Execution
For a full demonstration execute the GitHub Action workflows in this order:
1. `base_env_setup`
2. `build_and_deploy_flask_docker_img`
3. `devops_snowflake_deploy`

At this point, you should be able to use the code provided in `utility/demo_walkthrough.sql` within Snowflake's SQL Workbook to explore the environment. 

Within that code is `SHOW ENDPOINTS IN SERVICE API;` which will provide you with the endpoint to access the Flask API. Navigating to `<api-endpoint-url>/test` brings you to an HTML page to test the Flask API leveraging the Snowflake SQL Connector or Snowpark Python Connector against Kaggle data.

Once finished, run `reset_env_to_fresh`.

## To-Do/Optimize
* Improve least privilege / access management within the Snowflake instance.
* Normalize column names to non-case sensitive within load procedure
* Provide naming option or auto_naming of column after aggregation in load procedure
* More flexible Kaggle API file retrieval (csv, zip, json)
* GitHub file staging
* Row Access Policy mapping table instead of hardcoded mappings


## Cleanup
To reset the Snowflake environment back to a fresh one, sans all of the data, objects, apps, and roles we created, execute `reset_env_to_fresh` GitHub Action workflow. This executes `utility/full_cleanup.py` against your Snowflake account.


## References
Besides plenty of general use of [Snowflake's documentation](https://docs.snowflake.com/) overall, there are a few specific resources of QuickStart Guides or Tutorial docs which were particularly impactful. 

### GitHub Actions & schemachange
* [DevOps: Database Change Management with schemachange and GitHub](https://quickstarts.snowflake.com/guide/devops_dcm_schemachange_github/#0)
* [schemachange GitHub](https://github.com/Snowflake-Labs/schemachange)


### Flask API
* [Build a Custom API in Python and Flask](https://quickstarts.snowflake.com/guide/build_a_custom_api_in_python/index.html?index=..%2F..index#0)
* [Tutorial 1: Create a Snowpark Container Services Service](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/tutorials/tutorial-1#create-a-service)