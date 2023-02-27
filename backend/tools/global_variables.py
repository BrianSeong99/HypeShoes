from flask import g

def get_is_upload():
  if 'is_upload' not in g:
    g.is_upload = False
  return g.is_upload

def set_is_upload(val):
  g.is_upload = val

def get_device_1_ip():
  if 'device_1_ip' not in g:
    g.device_1_ip = "0.0.0.0"
  return g.device_1_ip

def set_device_1_ip(val):
  g.device_1_ip = val

def get_device_2_ip():
  if 'device_2_ip' not in g:
    g.device_2_ip = "0.0.0.0"
  return g.device_2_ip

def set_device_2_ip(val):
  g.device_2_ip = val