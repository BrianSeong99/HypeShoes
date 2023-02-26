from flask import Flask
from flask import request
import json
import time
import requests

app = Flask(__name__)

isUpload = False
ESP32 = "/esp32"
USER = "/user"

deviceIP = "0.0.0.0"

@app.route("/")
def setup():
    return "hello_world"

# user initiate or stop recording
# accessed by user
@app.route(USER + "/record", methods=["POST"])
def check_upload():
    if deviceIP == "0.0.0.0":
        return "No Device Registered"
    global isUpload
    status = request.args.get('status', 'false')
    frequency = request.args.get('frequency', '100')
    url = "http://" + deviceIP
    if status == 'true':
        print("true here")
        isUpload = True
        url = url + "/start?frequency=" + frequency    
    else:
        print("false here")
        isUpload = False
        url = url + "/stop"
    response = requests.request("GET", url, headers={}, data={})
    return response.text

# register device when booting
# accessed by esp32
@app.route(ESP32 + "/register", methods=["POST"])
def register_device():
    global isUpload
    global deviceIP
    deviceIP = request.remote_addr
    data = request.form
    device_id = data['deviceID']
    print("Device Registered", deviceIP, device_id) # database
    return "done"

# record the start and stop data
# accessed by esp32
@app.route(ESP32 + "/record", methods=["POST"])
def start_recording():
    global isUpload
    if isUpload is False:
        return "Not authorized to upload"
    else:
        data = request.form
        device_id = data['deviceID']
        is_recording = bool(data['record'])
        if is_recording:
            start_time = time.time()
            isUpload = True
            print(" Start Recording: ", device_id, start_time, isUpload)
        else:
            isUpload = False
            print(" Stop Recording: ", device_id, isUpload)
        return "done"

# after calling esp32/record to start, then using this to upload data
# accessed by esp32
@app.route(ESP32 + "/upload", methods=["POST"])
def upload_data():
    global isUpload
    print("here1", isUpload)
    if isUpload is False:
        return "Not authorized to upload"
    else:
        data = request.form
        print("here")
        print(data)
        return "uploaded"