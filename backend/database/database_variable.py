from os import environ
import pymongo

client = pymongo.MongoClient(environ.get("MONGO_URL"))
db_v0 = client.get_database('v0')
