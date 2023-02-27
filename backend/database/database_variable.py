from os import environ
import pymongo

client = pymongo.MongoClient(environ.get("MONGO_URL"))
db_users = client.get_database('users')
db_records = client.get_database('records')
