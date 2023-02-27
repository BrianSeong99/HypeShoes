from flask import Flask
from flask import request
from os import environ

from request_handler.esp_requests import *
from request_handler.client_requests import *
from request_handler.login_requests import *

app = Flask(__name__)
app.secret_key = environ.get("SECRET_KEY")

ESP32 = "/esp32"
USER = "/user"

@app.route("/signup", methods=['POST', 'GET'])
def signup():
    method = request.method
    fullname = request.form.get("fullname")
    email = request.form.get("email")
    password1 = request.form.get("password1")
    password2 = request.form.get("password2")
    return signup_handler(method, fullname, email, password1, password2)

@app.route('/logged_in')
def logged_in():
    return logged_in_handler()

@app.route("/login", methods=["POST", "GET"])
def login():
    method = request.method
    email = request.form.get("email")
    password = request.form.get("password")
    return login_handler(method, email, password)

@app.route("/logout", methods=["POST", "GET"])
def logout():
    return logout_handler()

# user initiate or stop recording
# accessed by user
@app.route(USER + "/record", methods=["POST"])
def check_upload():
    status = request.args.get('status', 'false')
    frequency = request.args.get('frequency', '100')
    return check_upload_handler(status, frequency)

# register device when booting
# accessed by esp32
@app.route(ESP32 + "/register", methods=["POST"])
def register_device():
    deviceIP = request.remote_addr
    data = request.form
    return register_device_handler(deviceIP, data)

# record the start and stop data
# accessed by esp32
@app.route(ESP32 + "/record", methods=["POST"])
def record_status():
    data = request.form
    return record_status_handler(data)

# after calling esp32/record to start, then using this to upload data
# accessed by esp32
@app.route(ESP32 + "/upload", methods=["POST"])
def upload_data():
    data = request.form
    return upload_data_handler(data)