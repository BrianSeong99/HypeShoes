from flask import Flask, session, url_for, redirect
from flask import request
import pymongo
import bcrypt
import time
import requests
from os import environ

app = Flask(__name__)
app.secret_key = environ.get("SECRET_KEY")
client = pymongo.MongoClient(environ.get("MONGO_URL"))
db = client.get_database('total_records')
records = db.register

isUpload = False
ESP32 = "/esp32"
USER = "/user"

deviceIP = "0.0.0.0"

@app.route("/signup", methods=['POST', 'GET'])
def index():
    message = 'Please login to your account'
    if "email" in session:
        return redirect(url_for("logged_in"))
    if request.method == "POST":
        user = request.form.get("fullname")
        email = request.form.get("email")
        
        password1 = request.form.get("password1")
        password2 = request.form.get("password2")
        
        user_found = records.find_one({"name": user})
        email_found = records.find_one({"email": email})
        if user_found:
            message = 'There already is a user by that name'
            return message
        if email_found:
            message = 'This email already exists in database'
            return message
        if password1 != password2:
            message = 'Passwords should match!'
            return message
        else:
            hashed = bcrypt.hashpw(password2.encode('utf-8'), bcrypt.gensalt())
            user_input = {'name': user, 'email': email, 'password': hashed}
            records.insert_one(user_input)
            
            user_data = records.find_one({"email": email})
            new_email = user_data['email']
   
            return new_email + "user loggined"
    return "done"

@app.route('/logged_in')
def logged_in():
    if "email" in session:
        email = session["email"]
        return "logged in " + email
    else:
        return redirect(url_for("login"))

@app.route("/login", methods=["POST", "GET"])
def login():
    message = 'Please login to your account'
    if "email" in session:
        return redirect(url_for("logged_in"))

    if request.method == "POST":
        email = request.form.get("email")
        password = request.form.get("password")

       
        email_found = records.find_one({"email": email})
        if email_found:
            email_val = email_found['email']
            passwordcheck = email_found['password']
            
            if bcrypt.checkpw(password.encode('utf-8'), passwordcheck):
                session["email"] = email_val
                return redirect(url_for("logged_in"))
            else:
                if "email" in session:
                    return redirect(url_for("logged_in"))
                message = 'Wrong password'
                return message
        else:
            message = 'Email not found'
            return message
    return message

@app.route("/logout", methods=["POST", "GET"])
def logout():
    if "email" in session:
        session.pop("email", None)
        return "signed out"
    else:
        return "main page"

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