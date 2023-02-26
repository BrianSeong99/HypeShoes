from flask import Flask
from flask import request
import json
import time


app = Flask(__name__)

isUpload = False

@app.route("/")
def setup():
    return "hello_world"

@app.route("/registerdevice", methods=["POST"])
def register_device():
    ip = request.remote_addr
    data = request.form
    device_id = data['deviceID']
    print("Device Registered", ip, device_id) # database
    return "done"

@app.route("/uploadcheck", methods=["GET", "POST"])
def check_upload():
    global isUpload
    if request.method == "GET":
        return json.dumps(isUpload)
    elif request.method == "POST":
        status = request.args.get('status', 'true')
        if status == 'true':
            print("true here")
            isUpload = True
        else:
            print("false here")
            isUpload = False
        return "status updated"

@app.route("/isRecording", methods=["POST"])
def start_recording():
    data = request.form
    device_id = data['deviceID']
    is_recording = bool(data['isRecording'])
    if is_recording:
        start_time = time.time()
        isUpload = True
        print(" Start Recording: ", device_id, start_time, isUpload)
    else:
        isUpload = False
        print(" Stop Recording: ", device_id, isUpload)
    return "done"

@app.route("/upload", methods=["POST"])
def upload_data():
    print("here1", isUpload)
    if isUpload is False:
        return "Not authorized to upload"
    else:
        data = request.form
        print("here")
        print(data)
        return "uploaded"