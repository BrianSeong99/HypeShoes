from flask import Flask, session, redirect, url_for
from flask import request
from flask_session import Session
from os import environ
import requests
from werkzeug.datastructures import MultiDict

from request_handler.esp_requests import *
# from request_handler.client_requests import *
from request_handler.login_requests import *
# from tools.global_variables import *

app = Flask(__name__)
app.secret_key = environ.get("SECRET_KEY")
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

ESP32 = "/esp32"
USER = "/user"

email = None
left_IP = "0.0.0.0"
right_IP = "0.0.0.0"
is_upload = False
record_id = None

@app.route("/signup", methods=['POST', 'GET'])
def signup():
    # if "email" in session: # later change to redis check userid
    # if get_email() is not None:
    global email
    if email is not None:
        return redirect(url_for("logged_in"))
    method = request.method
    fullname = request.form.get("fullname")
    email = request.form.get("email")
    password1 = request.form.get("password1")
    password2 = request.form.get("password2")
    return signup_handler(method, fullname, email, password1, password2)

@app.route('/logged_in')
def logged_in():
    # if "email" in session:
    # if get_email() is not None:
    global email
    if email is not None:
        # email = session["email"]
        return "logged in " + email
    else:
        return redirect(url_for("login"))

@app.route("/login", methods=["POST", "GET"])
def login():
    # if "email" in session:
    # if get_email() is not None:
    global email
    if email is not None:
        return redirect(url_for("logged_in"))
    method = request.method
    email = request.form.get("email")
    password = request.form.get("password")
    (message, status) = login_handler(method, email, password)
    if status:
        # session["email"] = message
        email = message
        # print(session["email"])
        return redirect(url_for('logged_in'))
    else:
        # print(session["email"])
        return message

@app.route("/logout", methods=["POST", "GET"])
def logout():
    # if "email" in session:
    #     session.pop("email", None)
    # if get_email() is not None:
    global email
    if email is not None:
        email = ""
        return "signed out"
    else:
        return "main page"

# user initiate or stop recording
# accessed by user
@app.route(USER + "/record", methods=["POST"])
def check_upload():
    global left_IP, right_IP, is_upload
    print(left_IP)
    print(right_IP)
    status = request.args.get('status', 'false')
    frequency = request.args.get('frequency', '100')
    # return check_upload_handler(status, frequency) # global variable not working....
    left_inactive = left_IP == "0.0.0.0"
    right_inactive = right_IP == "0.0.0.0"
    message = ''
    print(left_inactive)
    print(right_inactive)
    if left_inactive:
        message = "left is inactive"
    else:
        url_left = "http://" + left_IP
        if status == 'true':
            is_upload = True
            url_left = url_left + "/start?frequency=" + frequency    
        else:
            is_upload = False
            url_left = url_left + "/stop"
        message = requests.request("GET", url_left, headers={}, data={}).text + "\n"
    
    if right_inactive:
        message = "right is inactive"
    else:
        print("inside else")

        url_right = "http://" + right_IP
        if status == 'true':
            is_upload = True
            url_right = url_right + "/start?frequency=" + frequency    
        else:
            is_upload = False
            url_right = url_right + "/stop"
        print("right url: ", url_right)

        message = message + requests.request("GET", url_right, headers={}, data={}).text
    return message

# register device when booting
# accessed by esp32
@app.route(ESP32 + "/register", methods=["POST"])
def register_device():
    global left_IP, right_IP
    IP = request.remote_addr
    device_id = request.form['deviceID']
    if int(device_id) % 2 == 0 :
        left_IP = IP
    else:
        right_IP = IP
    # if "email" in session: # later change to redis check userid
    # if get_email() is not None:
    global email
    if email is not None:
        return register_device_handler(IP, email, device_id)
    else:
        return "Not Loggin yet"

# record the start and stop data
# accessed by esp32
@app.route(ESP32 + "/record", methods=["POST"])
def record_status():
    global is_upload, record_id
    data = request.form
    # return record_status_handler(data)
    if is_upload:
        device_id = data['deviceID']
        is_recording = bool(data['record'])
        if is_recording:
            is_upload = True
            record_id = start_new_record(email, device_id)
            return "Start Uploading"
        else:
            is_upload = False
            record_id = None
            print(" Stop Recording: ", device_id, False)
            return "Stop Recording"
    else:
        return "Not started, is_upload is False"

# after calling esp32/record to start, then using this to upload data
# accessed by esp32
@app.route(ESP32 + "/upload", methods=["POST"])
def upload_data():
    global is_upload, record_id
    data = request.form
    # return upload_data_handler(data)
    if is_upload is False:
        return "Not uploaded"
    else:
        insert_new_entry(data, record_id)
        return "Uploaded"