--Creating Python stored procedure for Kaggle dataset ETL
USE SCHEMA DKU_DEMO.{{schema_name}};

CREATE OR REPLACE PROCEDURE load_kaggle_dataset(dataset_owner STRING, dataset_name STRING, transform OBJECT)
RETURNS INT
LANGUAGE PYTHON
RUNTIME_VERSION = 3.8
HANDLER = 'load_kaggle_dataset'
EXTERNAL_ACCESS_INTEGRATIONS = (kaggle_api_access_integration)
PACKAGES = ('snowflake-snowpark-python', 'requests', 'pandas')
SECRETS = ('cred' = public.kaggle_central_auth)
AS
$$
import _snowflake
import snowflake.snowpark as snowpark
from snowflake.snowpark.types import StructType, StructField, StringType, IntegerType, FloatType, DoubleType, BooleanType, DateType, TimestampType
import requests
import pandas as pd
import io
import zipfile

def load_kaggle_dataset(session, dataset_owner: str, dataset_name: str, transform=None):
    '''
    Requests to download a dataset directly from Kaggle, performs optional transformations
    on the resulting DataFrame, and loads the data into a raw Snowflake table.

    Args:
        dataset_owner (str): Kaggle username of dataset owner
        dataset_name (str): name of Kaggle dataset
        transform (dict, optional): dictionary containing 'cat' 
            and 'agg' keys containing instructions for Pandas groupby and agg functions
    Returns:
        int: count of rows in created dataset, -1 if no dataset is discovered


    Raises:
        AssertionError: Raises an assertion error if provided parameters are not valid.
    '''
    kaggle_auth =_snowflake.get_username_password('cred')
    kaggle_user, kaggle_token = kaggle_auth.username, kaggle_auth.password

    assert isinstance(dataset_owner, str), \
        "dataset_owner parameter is not a str"
    assert isinstance(dataset_name, str), \
        "dataset_name parameter is not a str"

    kaggle_url = f"https://www.kaggle.com/api/v1/datasets/download/{dataset_owner}/{dataset_name}"
    kaggle_file_stage = '@KAGGLE_FILES'
    kaggle_file_name = f"{dataset_owner}_{dataset_name}.csv"

    response = requests.get(kaggle_url, auth=(kaggle_user, kaggle_token), timeout=120)

    if response.status_code == 200:
        with zipfile.ZipFile(io.BytesIO(response.content)) as z:
            with z.open(z.namelist()[0]) as file:
                results_df = pd.read_csv(file)
                results_df = session.createDataFrame(results_df, generate_struct_type_from_pandas(results_df))
                if transform is not None:
                    assert isinstance(transform, dict), \
                        "transform parameter provided is not a dict"
                    # transform must contain a 'cat' key containing a list of intended categories
                    # for aggregation to be performed ex. ['Platform', 'Year']
                    assert 'cat' in transform.keys(), \
                        "transform dict does not contain key 'cat'"
                    assert isinstance(transform['cat'], list), \
                        "transform dict value for key 'cat' is not a list"
                    # transform must contain a 'aggr' key containing a dictionary with
                    # column name : aggregation method(s) as key:pair
                    # ex. {'Global_Sales': 'sum'} or {'Global_Sales': ['sum', 'mean']}
                    assert 'agg' in transform.keys(), \
                        "transform dict does not contain key 'trans"
                    assert isinstance(transform['agg'], dict), \
                        "transform dict value for key 'aggr' is not a dict"
                    
                    results_df = results_df.group_by(transform['cat']).agg(transform['agg'])
                results_df.write.mode("overwrite").save_as_table(dataset_name)
                return results_df.count()
    else:
        return -1

# helper function for mapping pandas types to snowpark dataframe types
def map_pandas_dtype_to_snowpark(dtype):
    if pd.api.types.is_integer_dtype(dtype):
        return IntegerType()
    elif pd.api.types.is_float_dtype(dtype):
        return DoubleType()
    elif pd.api.types.is_bool_dtype(dtype):
        return BooleanType()
    elif pd.api.types.is_datetime64_any_dtype(dtype):
        return TimestampType()
    else:
        return StringType()

# helper function for generating the schema StructType for Snowflake DataFrame
def generate_struct_type_from_pandas(df):
    fields = [StructField(name, map_pandas_dtype_to_snowpark(dtype)) for name, dtype in df.dtypes.items()]
    return StructType(fields)
$$;