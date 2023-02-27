from flask import session, url_for, redirect
import bcrypt

from database.user import *

def signup_handler(request_method, fullname, email, pw1, pw2):
  message = 'index page'
  if "email" in session: # later change to redis check userid
    return redirect(url_for("logged_in"))
  if request_method == "POST":
    user_found = get_user_with_name(fullname)
    email_found = get_user_with_email(email)
    if user_found:
      message = 'There already is a user by that name'
    if email_found:
      message = 'This email already exists in database'
    if pw1 != pw2:
      message = 'Passwords should match!'
    else:
      hashed = bcrypt.hashpw(pw2.encode('utf-8'), bcrypt.gensalt())
      user_input = {'name': fullname, 'email': email, 'password': hashed.decode("UTF-8"), 'records': []}
      insert_new_user(user_input)
      user_data = get_user_with_email(email)
      new_email = user_data['email']
      return new_email + " logged_in"
  return message

def logged_in_handler():
  if "email" in session:
    email = session["email"]
    return "logged in " + email
  else:
    return redirect(url_for("login"))
  
def login_handler(request_method, email, pw):
  message = 'Please login to your account'
  if "email" in session:
    return redirect(url_for("logged_in"))
  if request_method == "POST":
    email_found = get_user_with_email(email)
    if email_found:
      email_val = email_found['email']
      password_check = email_found['password']
        
      if bcrypt.checkpw(pw.encode('utf-8'), password_check.encode('utf-8')):
        session["email"] = email_val
        return redirect(url_for('logged_in'))
      else:
        if "email" in session:
          return redirect(url_for("logged_in"))
        message = 'Wrong password'
        return message
    else:
      message = 'Email not found'
      return message
  return message

def logout_handler():
  if "email" in session:
    session.pop("email", None)
    return "signed out"
  else:
    return "main page"