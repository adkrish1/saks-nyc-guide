import json


def slot_validate(slots):
    if slots['no_of_restaurants'] == "":
        print('no_of_restaurants empty')
        return {
            'isValid': False,
            'inValidSlot': 'no_of_restaurants'
        }
    
    if slots['cuisine'] == "":
        print('cuisine empty')
        return {
            'isValid': False,
            'inValidSlot': 'cuisine'
        }
    if slots['no_of_attractions'] == "":
        print('no_of_attractions empty')
        return {
            'isValid': False,
            'inValidSlot': 'no_of_attractions'
        }
    return {
        'isValid': True
    }
        


def lambda_handler(event, context):
    # TODO implement
    print(event)
    
    bot = event['bot']['name']
    slots = event['sessionState']['intent']['slots']
    intent = event['sessionState']['intent']['name']
    
    validation_result = slot_validate(slots)
    
    
    if event['invocationSource'] == "DialogCodeHook":
        if validation_result['isValid'] == True:
            return {
                "sessionState": {
                    "dialogAction": {
                        "type": "Delegate"
                    },
                    "intent": {
                        'name': intent,
                        'slots': slots
                    }
                }
            }
        else:
            return {
                    "sessionState": {
                        "dialogAction": {
                            "slotToElicit": validation_result['invalidSlot'],
                            "type": "ElicitSlot"
                        },
                        "intent": {
                            "name": intent,
                            "slots": slots
                        }
                    }
                }
    
    if event['invocationSource'] == "FulfillmentCodeHook":
        print("comes here")
        print(slots)
        return {
            "sessionState": {
                "dialogAction": {
                    "type": "Close"
                },
                "intent": {
                    "name": intent,
                    "slots": slots,
                    "state": "Fulfilled"
                }

            },
            "messages": [
                {
                    "contentType": "PlainText",
                    "content": "I've placed your order."
                }
            ]
        }
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
