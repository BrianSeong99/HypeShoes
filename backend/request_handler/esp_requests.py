from tools.global_variables import *
import time

def register_device_handler(IP, data):
  set_device_1_ip(IP)
  device_id = data['deviceID']
  print("Device Registered", get_device_1_ip(), device_id) # database
  return "Device Registered"

def record_status_handler(data):
  if get_is_upload():
    device_id = data['deviceID']
    is_recording =bool(data['record'])
    if is_recording:
      start_time = time.time()
      set_is_upload(True)
      print(" Start Recording: ", device_id, start_time, True)
    else:
      set_is_upload(False)
      print(" Stop Recording: ", device_id, False)
    return "Start Uploading"
  else:
    return "Not started, is_upload is False"
  
def upload_data_handler(data):
  if get_is_upload() is False:
      return "Not authorized to upload"
  else:
      print(data)
      return "Not uploaded, is_upload is False"