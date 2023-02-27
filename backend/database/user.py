from database.database_variable import *
from database.schema import user_schema
from jsonschema import validate

users_col = db_v0.users

def get_user_with_name(fullname):
  return users_col.find_one({"name": fullname})

def get_user_with_email(email):
  return users_col.find_one({"email": email})

def insert_new_user(user_data):  
  validate(instance=user_data, schema=user_schema)
  users_col.insert_one(user_data)
