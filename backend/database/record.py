from database.schema import user_schema
from jsonschema import validate
from database.database_variable import *

records = db.register

def new_or_update_user(data):
  validate(instance=data, schema=user_schema)
  print("there")