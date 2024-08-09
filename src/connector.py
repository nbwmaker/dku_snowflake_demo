import datetime
import os

import snowflake.connector
from snowflake.connector import DictCursor
from flask import Blueprint, request, abort, jsonify, make_response

# Make the Snowflake connection
def connect() -> snowflake.connector.SnowflakeConnection:
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
    return snowflake.connector.connect(**creds)

conn = connect()

# Make the API endpoints
connector = Blueprint('connector', __name__)

## Sales per platform by company for the year
@connector.route('/company/<company_name>/yearly_sales/<year>')
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
    sql_string = '''
        SELECT *
        FROM kaggle_datasets.videogamesales
        WHERE "Platform" IN {platform_list}
        AND "Year" = {year}
    '''
    sql = sql_string.format(year=year_int, platform_list = company_to_platform_map[company_name])
    try:
        res = conn.cursor(DictCursor).execute(sql)
        return make_response(jsonify(res.fetchall()))
    except:
        abort(500, "Error reading from Snowflake.")