from database.schema import user_schema
from jsonschema import validate
from bson.objectid import ObjectId
from database.database_variable import *
import time
import math

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

def get_stride_average(record_data):
  gravity = 9.81
  stride_threshold = 0.4 # in m/s^2

  vel = [0, 0, 0]
  pos = [0, 0, 0]
  stride_start = False
  stride_end = False
  last_vel = 0
  sample_rate = 100

  counter = 0

  for index, data in enumerate(record_data):
    lax = (float(data[5]) / 16384.0) * gravity
    lay = (float(data[6]) / 16384.0) * gravity
    laz = (float(data[7]) / 16384.0) * gravity

    vel[0] += lax * (1/sample_rate)
    vel[1] += lay * (1/sample_rate)
    vel[2] += laz * (1/sample_rate)
    pos[0] += vel[0] * (1/sample_rate)
    pos[1] += vel[1] * (1/sample_rate)
    pos[2] += vel[2] * (1/sample_rate)

    # Check for stride start
    if lax > stride_threshold and not stride_start:
        stride_start = True

    # Check for stride end
    if last_vel > 0 and vel[1] < 0 and stride_start:
        stride_end = True

    if stride_end:
        stride_length = math.sqrt((pos[0]**2) + (pos[1]**2) + (pos[2]**2))
        print("Stride length: %.2f meters" % stride_length)
        counter = counter + stride_length
        stride_start = False
        stride_end = False
    
    last_vel = vel[1]
  
  return counter / len(data)

def get_record_result(record_id_prev):
  if record_id_prev == None:
    return {"result": [0.0, 0.0]}
  record = records_col.find_one({"_id": ObjectId(record_id_prev)})
  left_stride = get_stride_average(record['left_sequence_data'])
  right_stride = get_stride_average(record['right_sequence_data'])
  print("stride", left_stride, right_stride)
  # left_stride = 1.0
  # right_stride = 2.0
  return {"result": [left_stride, right_stride]}

