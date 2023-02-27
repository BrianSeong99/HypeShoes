import bcrypt

from database.user import *

def signup_handler(request_method, fullname, email, pw1, pw2):
  message = 'index page'
  if request_method == "POST":
    user_found = get_user_with_name(fullname)
    email_found = get_user_with_email(email)
    print(type(user_found))
    print(email_found)
    if user_found:
      message = 'There already is a user by that name'
      return message
    if email_found:
      message = 'This email already exists in database'
      return message
    if pw1 != pw2:
      message = 'Passwords should match!'
    else:
      hashed = bcrypt.hashpw(pw2.encode('utf-8'), bcrypt.gensalt())
      user_input = {
        'name': fullname, 'email': email, 'password': hashed.decode("UTF-8"), 
        'records': [], "devices": []
      }
      insert_new_user(user_input)
      user_data = get_user_with_email(email)
      new_email = user_data['email']
      return new_email + " logged_in"
  return message
  
def login_handler(request_method, email, pw):
  message = 'Please login to your account'
  if request_method == "POST":
    email_found = get_user_with_email(email)
    if email_found:
      email_val = email_found['email']
      password_check = email_found['password']
      if bcrypt.checkpw(pw.encode('utf-8'), password_check.encode('utf-8')):
        return (email_val, True)
      else:
        message = 'Wrong password'
        return (message, False)
    else:
      message = 'Email not found'
      return (message, False)
  return (message, False)