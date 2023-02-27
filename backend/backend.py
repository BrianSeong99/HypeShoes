from flask import Flask, session, redirect, url_for
from flask import request
from flask_session import Session
from os import environ

from request_handler.esp_requests import *
from request_handler.client_requests import *
from request_handler.login_requests import *
from tools.global_variables import *

app = Flask(__name__)
app.secret_key = environ.get("SECRET_KEY")
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

ESP32 = "/esp32"
USER = "/user"

email = None

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
    print(email)
    if email is not None:
        return redirect(url_for("logged_in"))
    method = request.method
    email = request.form.get("email")
    password = request.form.get("password")
    (message, status) = login_handler(method, email, password)
    print("loginnn, ", message)
    if status:
        print("login ", message)
        # session["email"] = message
        set_email(message)
        print(email)
        # print(session["email"])
        return redirect(url_for('logged_in'))
    else:
        # print(session["email"])
        return message

@app.route("/logout", methods=["POST", "GET"])
async def logout():
    # if "email" in session:
    #     session.pop("email", None)
    # if get_email() is not None:
    global email
    if email is not None:
        await set_email("")
        return "signed out"
    else:
        return "main page"

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
    # if "email" in session: # later change to redis check userid
    # if get_email() is not None:
    global email
    if email is not None:
        return register_device_handler(deviceIP, email, data)
    else:
        return "Not Loggin yet"

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