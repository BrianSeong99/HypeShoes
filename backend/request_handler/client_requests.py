from tools.global_variables import *
import requests

def check_upload_handler(status, frequency):
  if get_device_1_ip() == "0.0.0.0":
    return "No Device Registered"
  url = "http://" + get_device_1_ip()
  if status == 'true':
    print("true here")
    set_is_upload(True)
    url = url + "/start?frequency=" + frequency    
  else:
    print("false here")
    set_is_upload(False)
    url = url + "/stop"
  response = requests.request("GET", url, headers={}, data={})
  return response.text