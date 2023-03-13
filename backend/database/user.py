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

def update_devices_with_email(email, deviceID):
  user = users_col.find_one({"email": email})
  if user == None:
    return 'user not found'
  devices = user['devices']
  if devices is None or devices == []:
    devices = [deviceID]
  elif deviceID in devices:
    return "already Registered"
  else:
    devices.append(deviceID)
  users_col.update_one({"email": email}, {"$set": {"devices": devices}})
  user = users_col.find_one({"email": email})
  devices = user['devices']
  return "registered successfully, current device list: " + str(devices)
