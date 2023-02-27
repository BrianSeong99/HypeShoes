from os import environ
import pymongo

client = pymongo.MongoClient(environ.get("MONGO_URL"))
db = client.get_database('total_records')
records = db.register