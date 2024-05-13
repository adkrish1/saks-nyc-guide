import json
import boto3
import secrets

import logging

from pip._vendor import requests
import asyncio

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

def get_llm_response(cuisine, no_of_restaurants, no_of_attractions):
    
    old_ec2_instance = "54.237.82.79"
    new_ec2_instance = "54.90.133.71"
    
    restaurant_question = f"Give me {no_of_restaurants} restaurants with {cuisine} cuisine in a json format all the details"
    
    base_url = f"http://{new_ec2_instance}:6969/llm?question={restaurant_question}"
    
    attraction_question = f"Give me {no_of_attractions} attraction in a json format all the details"
    
    
    restaurant_response = requests.get(base_url).json()
    
    base_url = f"http://{new_ec2_instance}:6969/llm?question={attraction_question}"
    
    print("restaurant response")
    print(restaurant_response)
    
    
    attraction_response = requests.get(base_url).json()
    
    print("attraction response")
    print(attraction_response)
    
    
    attraction_response['response']['restaurants'] = restaurant_response['response']['restaurants']
    
    
    
    
    
    return attraction_response
    

def lambda_handler(event, context):

    #botId='T8MJBDCACE'
    #botAliasId='TSTALIASID'
    botId='T8MJBDCACE'
    botAliasId='JPUWOB0GO1'
    localeId='en_US'

    client = boto3.client('lexv2-runtime')
    print(event)
    body = json.loads(event['body'])
    
    # messages = body['messages']
    # print(body)
    # print(messages)

    logger.debug("###############")
    logger.debug(body)
    logger.debug("###############")

    response = client.recognize_text(
        botId=botId,
        botAliasId=botAliasId,
        localeId=localeId,
        sessionId="sessionId2sda",
        text=body['messages'][0]['text'] 
    )
    
    print(response)
    
    dialogAction = response['sessionState']['dialogAction']['type']
    intentName = response['sessionState']['intent']['name']
    print(f'dialogAction = {dialogAction}')
    
    isLlmFetchFlag = False
    llm_response = ""
    #llm_string = '{"response": {"attractions": [{"Address": "11 West 53rd St New York, NY 10019", "Categories": "Art Museums", "Friday": "10:30 - 17:30", "Latitude": "40.761441", "Longitude": "-73.977625", "Monday": "10:30 - 17:30", "Name": "The Museum of Modern Art", "Phone": "12127089400", "Rating": 4.4, "Saturday": "10:30 - 19:00", "Sunday": "10:30 - 17:30", "Thursday": "10:30 - 17:30", "Tuesday": "10:30 - 17:30", "Wednesday": "10:30 - 17:30"}, {"Address": "89 E 42nd St New York, NY 10017", "Categories": "Landmarks & Historical Buildings, Train Stations", "Friday": "05:30 - 02:00", "Latitude": "40.752727697036576", "Longitude": "-73.97723946", "Monday": "05:30 - 02:00", "Name": "Grand Central Terminal", "Phone": "12123402583", "Rating": 4.6, "Saturday": "05:30 - 02:00", "Sunday": "05:30 - 02:00", "Thursday": "05:30 - 02:00", "Tuesday": "05:30 - 02:00", "Wednesday": "05:30 - 02:00"}, {"Address": "1000 Fifth Ave New York, NY 10028", "Categories": "Art Museums", "Friday": "10:00 - 21:00", "Latitude": "40.779449", "Longitude": "-73.963245", "Monday": "10:00 - 17:00", "Name": "The Metropolitan Museum of Art", "Phone": "12125357710", "Rating": 4.7, "Saturday": "10:00 - 21:00", "Sunday": "10:00 - 17:00", "Thursday": "10:00 - 17:00", "Tuesday": "10:00 - 17:00", "Wednesday": ""}], "restaurants": [{"Address": "338 E 92nd St New York, NY 10128", "Friday": "16:30 - 00:00", "Latitude": 40.78098, "Longitude": -73.94751, "Monday": "16:30 - 00:00", "Name": "The Drunken Munkey - UES", "Phone": "16468468986", "Price Range": "$$", "Rating": 4.3, "Saturday": "16:30 - 00:00", "Sunday": "16:30 - 00:00", "Thursday": "16:30 - 00:00", "Tuesday": "16:30 - 00:00", "Wednesday": "16:30 - 00:00"}, {"Address": "129 E 27th St New York, NY 10016", "Friday": "17:00 - 23:00", "Latitude": 40.74241, "Longitude": -73.98325, "Monday": "17:00 - 22:30", "Name": "Pippali", "Phone": "12126891999", "Price Range": "$$", "Rating": 4.1, "Saturday": "17:00 - 23:00", "Sunday": "17:00 - 22:30", "Thursday": "17:00 - 22:30", "Tuesday": "17:00 - 22:30", "Wednesday": "17:00 - 22:30"}, {"Address": "240 W 35th St New York, NY 10001", "Friday": "11:30 - 23:30", "Latitude": 40.752147, "Longitude": -73.991864, "Monday": "11:30 - 23:30", "Name": "Patiala Indian Grill  & Bar", "Phone": "12125648255", "Price Range": "No price info", "Rating": 4.5, "Saturday": "11:30 - 23:30", "Sunday": "11:30 - 23:30", "Thursday": "11:30 - 23:30", "Tuesday": "11:30 - 23:30", "Wednesday": "11:30 - 23:30"}, {"Address": "764 9th Ave New York, NY 10019", "Friday": "11:00 - 22:45", "Latitude": 40.76421, "Longitude": -73.988101, "Monday": "11:00 - 22:00", "Name": "Bombay Grill House", "Phone": "12129771010", "Price Range": "$$", "Rating": 4.1, "Saturday": "11:30 - 22:45", "Sunday": "11:30 - 22:00", "Thursday": "11:00 - 22:00", "Tuesday": "11:00 - 22:00", "Wednesday": "11:00 - 22:00"}, {"Address": "31 Cornelia St New York, NY 10014", "Friday": "16:00 - 00:00", "Latitude": 40.73136, "Longitude": -74.00253, "Monday": "16:00 - 00:00", "Name": "Bombay Bistro", "Phone": "16468503719", "Price Range": "$$", "Rating": 4.4, "Saturday": "11:30 - 00:00", "Sunday": "11:30 - 00:00", "Thursday": "16:00 - 00:00", "Tuesday": "16:00 - 00:00", "Wednesday": "16:00 - 00:00"}]}}'
    #llm_string = '{"response": {"attractions": [{"Address": "11 West 53rd St New York, NY 10019", "Categories": "Art Museums", "Friday": "10:30 - 17:30", "Latitude": 40.761441, "Longitude": -73.977625, "Monday": "10:30 - 17:30", "Name": "The Museum of Modern Art", "Phone": "12127089400", "Rating": 4.4, "Saturday": "10:30 - 19:00", "Sunday": "10:30 - 17:30", "Thursday": "10:30 - 17:30", "Tuesday": "10:30 - 17:30", "Wednesday": "10:30 - 17:30"}, {"Address": "89 E 42nd St New York, NY 10017", "Categories": "Landmarks & Historical Buildings, Train Stations", "Friday": "05:30 - 02:00", "Latitude": 40.752727697036576, "Longitude": -73.97723946, "Monday": "05:30 - 02:00", "Name": "Grand Central Terminal", "Phone": "12123402583", "Rating": 4.6, "Saturday": "05:30 - 02:00", "Sunday": "05:30 - 02:00", "Thursday": "05:30 - 02:00", "Tuesday": "05:30 - 02:00", "Wednesday": "05:30 - 02:00"}, {"Address": "1000 Fifth Ave New York, NY 10028", "Categories": "Art Museums", "Friday": "10:00 - 21:00", "Latitude": 40.779449, "Longitude": -73.963245, "Monday": "10:00 - 17:00", "Name": "The Metropolitan Museum of Art", "Phone": "12125357710", "Rating": 4.7, "Saturday": "10:00 - 21:00", "Sunday": "10:00 - 17:00", "Thursday": "10:00 - 17:00", "Tuesday": "10:00 - 17:00", "Wednesday": ""}], "restaurants": [{"Address": "338 E 92nd St New York, NY 10128", "Friday": "16:30 - 00:00", "Latitude": 40.78098, "Longitude": -73.94751, "Monday": "16:30 - 00:00", "Name": "The Drunken Munkey - UES", "Phone": "16468468986", "Price Range": "$$", "Rating": 4.3, "Saturday": "16:30 - 00:00", "Sunday": "16:30 - 00:00", "Thursday": "16:30 - 00:00", "Tuesday": "16:30 - 00:00", "Wednesday": "16:30 - 00:00"}, {"Address": "129 E 27th St New York, NY 10016", "Friday": "17:00 - 23:00", "Latitude": 40.74241, "Longitude": -73.98325, "Monday": "17:00 - 22:30", "Name": "Pippali", "Phone": "12126891999", "Price Range": "$$", "Rating": 4.1, "Saturday": "17:00 - 23:00", "Sunday": "17:00 - 22:30", "Thursday": "17:00 - 22:30", "Tuesday": "17:00 - 22:30", "Wednesday": "17:00 - 22:30"}, {"Address": "240 W 35th St New York, NY 10001", "Friday": "11:30 - 23:30", "Latitude": 40.752147, "Longitude": -73.991864, "Monday": "11:30 - 23:30", "Name": "Patiala Indian Grill  & Bar", "Phone": "12125648255", "Price Range": "No price info", "Rating": 4.5, "Saturday": "11:30 - 23:30", "Sunday": "11:30 - 23:30", "Thursday": "11:30 - 23:30", "Tuesday": "11:30 - 23:30", "Wednesday": "11:30 - 23:30"}, {"Address": "764 9th Ave New York, NY 10019", "Friday": "11:00 - 22:45", "Latitude": 40.76421, "Longitude": -73.988101, "Monday": "11:00 - 22:00", "Name": "Bombay Grill House", "Phone": "12129771010", "Price Range": "$$", "Rating": 4.1, "Saturday": "11:30 - 22:45", "Sunday": "11:30 - 22:00", "Thursday": "11:00 - 22:00", "Tuesday": "11:00 - 22:00", "Wednesday": "11:00 - 22:00"}, {"Address": "31 Cornelia St New York, NY 10014", "Friday": "16:00 - 00:00", "Latitude": 40.73136, "Longitude": -74.00253, "Monday": "16:00 - 00:00", "Name": "Bombay Bistro", "Phone": "16468503719", "Price Range": "$$", "Rating": 4.4, "Saturday": "11:30 - 00:00", "Sunday": "11:30 - 00:00", "Thursday": "16:00 - 00:00", "Tuesday": "16:00 - 00:00", "Wednesday": "16:00 - 00:00"}]}}'
    #llm_response = json.loads(llm_string)
        
    
    
    if dialogAction == "Close" and intentName == "ItenaryIntent":
        slots = response['sessionState']['intent']['slots']
        print(slots)
        
        cuisine = slots['cuisine']['value']['originalValue']
        no_of_attractions = slots['no_of_attractions']['value']['originalValue']
        no_of_restaurants = slots['no_of_restaurants']['value']['originalValue']
        
        print(f'{cuisine} , {no_of_attractions}, {no_of_restaurants}')
        
        
        llm_response = get_llm_response(cuisine, no_of_restaurants, no_of_attractions)
        print("response got it")
        print(llm_response)
        isLlmFetchFlag = True
    
        
        
        
    logger.debug("End of lambdaaaaa")
    logger.debug(llm_response)
    logger.debug(isLlmFetchFlag)
    body = response if llm_response == "" else llm_response
    body["isDataExist"] = isLlmFetchFlag
    logger.debug(body)
    logger.debug("##########")
    return {
		"statusCode": 200,
		"headers": {
			"Content-Type": "application/json"
		},
        'body': json.dumps(body),
		"isBase64Encoded": False
	}