from flask import g, session

def get_is_upload():
  if 'is_upload' not in g:
    g.is_upload = False
  return g.is_upload

def set_is_upload(val):
  g.is_upload = val

def get_device_left_ip():
  if 'device_left_ip' not in g:
    g.device_left_ip = "0.0.0.0"
  return g.device_left_ip

def set_device_left_ip(val):
  g.device_right_ip = val

def get_device_right_ip():
  if 'device_right_ip' not in g:
    g.device_right_ip = "0.0.0.0"
  return g.device_right_ip

def set_device_right_ip(val):
  g.device_2_ip = val

# not working..
def get_email():
  # print("getemail: ", 'email' not in g)
  if 'email' not in g:
    g.email = None
  return g.email

# not working..
def set_email(val):
  g.email = val