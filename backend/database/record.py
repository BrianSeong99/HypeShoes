from database.schema import user_schema
from jsonschema import validate
from database.database_variable import *

records_col = db_v0.records
users_col = db_v0.users

def start_new_record(email, device_id):
  new_data = {"left_sequence_data": [], "right_sequence_data": []}
  validate(instance=new_data, schema=user_schema)
  entry = records_col.insert_one(new_data)
  user = users_col.find_one({"email": email})
  records = user['records']
  if records == None:
    records = [entry.inserted_id]
  else:
    records.append(entry.inserted_id)
  users_col.update_one({"email": email}, {"$set": {"records": records}})
  return "record initiated"

