import sys
import logging
import pymysql
import json
import os
import sys
import logging
import pymysql
import json
import os
import json
from pip._vendor import requests
import logging
import time

user_name = os.environ['USER_NAME']
password = os.environ['PASSWORD']
rds_proxy_host = os.environ['RDS_PROXY_HOST']
db_name = os.environ['DB_NAME']

print(user_name)
print(password)
print(rds_proxy_host)
print(db_name)

api_key = "93rDb5l4dwpPQT77P_5rPlFTlbEN3Ura2ZTcHdGdtO_-u6dQu955k_-t5MGxkhZh37zQTafB0I97zrvXel9vD6DxqUec0dN7-8_I32rVGfolciRKzLXX9IGhpnU9ZnYx"
    
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

def get_sightseeing_data(api_key, cursor, connection, total=5, start_offset=0):
    headers = {
        'Authorization': f'Bearer {api_key}',
        'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.76 Safari/537.36',
        "Upgrade-Insecure-Requests": "1",
        "DNT": "1",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.5",
        "Accept-Encoding": "gzip, deflate"
    }
    limit = 5  # Max limit per request as allowed by the API

    url = f"https://api.yelp.com/v3/businesses/search?location=Manhattan&sort_by=best_match&limit={limit}&offset={start_offset}"
    response = requests.get(url, headers=headers)
    
    if response.status_code != 200:
        print(f"Failed to retrieve data: {response.status_code}")
        return
    
    data = response.json()
    for business in data.get('businesses', []):
        time.sleep(1)
        business_id = business['id']
        business_details_url = f"https://api.yelp.com/v3/businesses/{business_id}"
        details_response = requests.get(business_details_url, headers=headers)
        restaurant_data = details_response.json()

        name = restaurant_data['name']
        address = ', '.join(restaurant_data['location'].get('display_address', ['Address Not Available']))
        latitude = restaurant_data['coordinates']['latitude']
        longitude = restaurant_data['coordinates']['longitude']
        rating = restaurant_data.get('rating', 'Rating Not Available')
        phone = restaurant_data.get('display_phone', 'Phone Not Available')
        categories = ', '.join([category['title'] for category in restaurant_data.get('categories', [])])
        price_range = restaurant_data.get('price', '')
        hours = restaurant_data.get('hours', [{'open': []}])[0].get('open', [])
        days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        hours_dict = {day: f"{time['start']}-{time['end']}" for day, time in zip(days, hours)}


        sql_query = """
            INSERT INTO Restaurants(Name, Address, Latitude, Longitude, Rating, Phone, Categories, Price_Range, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        # # Extracting parameters from the restaurant data
        params = (
            name, address, latitude, longitude, rating, phone, categories, price_range,
            hours_dict.get("Monday", ""), hours_dict.get("Tuesday", ""), hours_dict.get("Wednesday", ""),
            hours_dict.get("Thursday", ""), hours_dict.get("Friday", ""), hours_dict.get("Saturday", ""),
            hours_dict.get("Sunday", "")
        )

        print(params)

        cursor.execute(sql_query, params)
        connection.commit()
                    
def lambda_handler():
    connection = pymysql.connect(host=rds_proxy_host, user=user_name, passwd=password, db=db_name, connect_timeout=5)
    
    cursor = connection.cursor()
    
    try:
        cursor.execute("SELECT COUNT(1) FROM Restaurants;")
        
        rows = cursor.fetchall()
        
        get_sightseeing_data(api_key=api_key, cursor=cursor, connection=connection, start_offset=rows[0][0])
        
        return {
            'statusCode': 200,
            'body': 'success(dummy message)'
        }
    except Exception as e:
        print(e, "Some exception occurred")
        return {
            'statusCode': 500,
            'body': str(e)
        }
    finally:
        # Close the database connection
        connection.close()
