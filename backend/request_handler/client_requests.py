from tools.global_variables import *
import requests

def check_upload_handler(status, frequency):
  left_inactive = get_device_left_ip() == "0.0.0.0"
  right_inactive = get_device_right_ip() == "0.0.0.0"
  print(get_device_left_ip())
  print(get_device_right_ip())
  message = ''
  if left_inactive:
    message = "left is inactive"
  else:
    url_left = "http://" + get_device_left_ip()
    if status == 'true':
      set_is_upload(True)
      url_left = url_left + "/start?frequency=" + frequency    
    else:
      set_is_upload(False)
      url_left = url_left + "/stop"
    message = requests.request("GET", url_left, headers={}, data={}).text + "\n"
  
  if right_inactive:
    message = "right is inactive"
  else:
    url_right = "http://" + get_device_left_ip()
    if status == 'true':
      set_is_upload(True)
      url_right = url_right + "/start?frequency=" + frequency    
    else:
      set_is_upload(False)
      url_right = url_right + "/stop"
    message = message + requests.request("GET", url_right, headers={}, data={}).text
  return message