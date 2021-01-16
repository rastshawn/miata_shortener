#https://python-twitter.readthedocs.io/en/latest/twitter.html#module-twitter.api

import twitter
import configparser
from os import path

config = configparser.ConfigParser()
config.read('config.ini')

if not path.exists('counter.txt'):
    newfile = open('counter.txt', 'w+')
    newfile.write(str(0))
    newfile.close()


counterFile = open('counter.txt', 'r+')
line = counterFile.readline()
counter = int(line)
counterFile.seek(0)
counterFile.write(str(counter+1))

print(counter)
counterFile.close()

if counter > int(config['DEFAULT']['max_num']):
    quit()

api = twitter.Api(consumer_key=config['DEFAULT']['consumer_key'],
consumer_secret=config['DEFAULT']['consumer_secret'],
access_token_key=config['DEFAULT']['access_token_key'],
access_token_secret=config['DEFAULT']['access_token_secret'])



img = open('images/datamiat' + str(counter) + '.jpg', 'rb')

#api.PostUpdates(status='',media='http://www.shawnrast.com/assets/images/headshot.jpg')
api.PostUpdates(status='',media=img)

