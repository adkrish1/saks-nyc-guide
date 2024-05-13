import sys
import logging
import pymysql
import json
import os

# # RDS database connection details
# host = 'plotting-data-db.cxouquo4mbsy.us-east-1.rds.amazonaws.com'
# user = 'admin'
# password = 'saksnyc123'
# database = 'plottingdatadb'

user_name = os.environ['USER_NAME']
password = os.environ['PASSWORD']
rds_proxy_host = os.environ['RDS_PROXY_HOST']
db_name = os.environ['DB_NAME']

print(user_name)
print(password)
print(rds_proxy_host)
print(db_name)

def lambda_handler(event, context):
    location = event['queryStringParameters']['location_type']
    # location = 'Subway'
    # print(location)
    # Establish a connection to the RDS database
    connection = pymysql.connect(host=rds_proxy_host, user=user_name, passwd=password, db=db_name, connect_timeout=5)
    
    # Create a cursor object to execute SQL queries
    cursor = connection.cursor()
    print("came here at")
    
    try:
        # Example SQL query to fetch data
        cursor.execute("SELECT * FROM plotdatatable;")
        
        # Fetch all rows from the result
        rows = cursor.fetchall()
        
        # Format the rows as per your requirement
        
        formatted_data = [{'Name': row[0], 'Latitude': row[1], 'Longitude': row[2], 'Location Type': row[3]} for row in rows if row[3] == location]
        
        print(formatted_data)
        
        return {
            'statusCode': 200,
            'body': json.dumps(formatted_data)
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': str(e)
        }
    finally:
        # Close the database connection
        connection.close()