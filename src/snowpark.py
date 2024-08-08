import datetime
import os

from flask import Blueprint, request, abort, make_response, jsonify

# Make the Snowflake connection
from snowflake.snowpark import Session
import snowflake.snowpark.functions as f

def connect() -> Session:
    if os.path.isfile("/snowflake/session/token"):
        creds = {
            'host': os.getenv('SNOWFLAKE_HOST'),
            'port': os.getenv('SNOWFLAKE_PORT'),
            'protocol': "https",
            'account': os.getenv('SNOWFLAKE_ACCOUNT'),
            'authenticator': "oauth",
            'token': open('/snowflake/session/token', 'r').read(),
            'warehouse': os.getenv('SNOWFLAKE_WAREHOUSE'),
            'database': os.getenv('SNOWFLAKE_DATABASE'),
            'schema': os.getenv('SNOWFLAKE_SCHEMA'),
            'client_session_keep_alive': True
        }
    else:
        creds = {
            'account': os.getenv('SNOWFLAKE_ACCOUNT'),
            'user': os.getenv('SNOWFLAKE_USER'),
            'password': os.getenv('SNOWFLAKE_PASSWORD'),
            'warehouse': os.getenv('SNOWFLAKE_WAREHOUSE'),
            'database': os.getenv('SNOWFLAKE_DATABASE'),
            'schema': os.getenv('SNOWFLAKE_SCHEMA'),
            'client_session_keep_alive': True
        }
    return Session.builder.configs(creds).create()

session = connect()

# Make the API endpoints
snowpark = Blueprint('snowpark', __name__)

## Sales per platform by company for the year
@snowpark.route('/company/<company_name>/yearly_sales/<year>')
def company_yearly_sales(company_name, year):
    company_to_platform_map = {
        "nintendo" : ('3DS', 'DS', 'GB', 'GBA', 'N64', 'NES', 'SNES', 'Wii', 'WiiU'),
        "sony" : ('PS', 'PS2', 'PS3', 'PS4', 'PSV', 'PSP'),
        "microsoft" : ('PC', 'XB', 'X360', 'XOne')
    }
    try:
        company_to_platform_map[company_name]
    except:
        abort(400, "Invalid company.")
    try:
        year_int = int(year)
    except:
        abort(400, "Invalid year.")
    try:
        df = session.table('KAGGLE_DATASETS.videogamesales') \
            .filter(f.col('"Platform"').in_(company_to_platform_map[company_name])) \
            .filter(f.col('"Year"') == year_int)
        return make_response(jsonify([x.as_dict() for x in df.to_local_iterator()]))
    except:
        abort(500, "Error reading from Snowflake.")
