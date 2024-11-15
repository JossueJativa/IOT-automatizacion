import json
import os
import firebase_admin
from firebase_admin import credentials, messaging

cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
firebase_admin.initialize_app(cred)

def send_message(token, title, body):
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        token=token
    )
    try:
        messaging.send(message)
        return True
    except Exception as e:
        return False