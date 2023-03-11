from database.schema import user_schema
from jsonschema import validate
from bson.objectid import ObjectId
from database.database_variable import *
import time

records_col = db_v0.records
users_col = db_v0.users

def start_new_record(email, device_id):
  new_data = {"timestamp": int(time.time()), "devices": [device_id], "left_sequence_data": [], "right_sequence_data": []}
  validate(instance=new_data, schema=user_schema)
  entry = records_col.insert_one(new_data)
  user = users_col.find_one({"email": email})
  records = user['records']
  if records == None:
    records = [entry.inserted_id]
  else:
    records.append(entry.inserted_id)
  users_col.update_one({"email": email}, {"$set": {"records": records}})
  return entry.inserted_id

def insert_new_entry(data, record_id, timestamp):
  r0 = data['reading0']
  r1 = data['reading1']
  r2 = data['reading2']
  r3 = data['reading3']
  r4 = data['reading4']
  ax = data['accelx']
  ay = data['accely']
  az = data['accelz']
  gx = data['gyrox']
  gy = data['gyroy']
  gz = data['gyroz']
  device_id = data['deviceID']
  new_data = [r0, r1, r2, r3, r4, ax, ay, az, gx, gy, gz, timestamp]
  if int(device_id) % 2 == 0 :
    records_col.update_one({ "_id": ObjectId(record_id) }, { "$push": { "left_sequence_data": new_data } })
  else:
    records_col.update_one({ "_id": ObjectId(record_id) }, { "$push": { "right_sequence_data": new_data } })

def get_record_entry(record_id): 
  record = records_col.find_one({"_id": ObjectId(record_id)})
  return record