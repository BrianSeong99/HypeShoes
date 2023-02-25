from flask import Flask
from flask import request
import json

app = Flask(__name__)

isUpload = True

@app.route("/")
def setup():
    return "hello_world"

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

@app.route("/upload", methods=["POST"])
def upload_data():
    if isUpload is not True:
        return "Not authorized to upload"
    else:
        print(request.args.get('ax', ''))
        return "uploaded"