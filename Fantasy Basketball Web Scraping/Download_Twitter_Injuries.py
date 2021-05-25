# -*- coding: utf-8 -*-
"""
Created on Wed Feb 10 15:01:10 2021

@author: v-mpurvis
"""

# Downloads latest injury tweets from fantasylabs on twitter

import tweepy
import pandas as pd
import time
from datetime import datetime, date, timedelta
import os
from collections import OrderedDict
import config

start_time = time.time()

today = datetime.today()

day = today.weekday()

if(day == 0):
    weekday = 'Monday'
elif(day == 1):
    weekday = 'Tuesday'
elif(day == 2):
    weekday = 'Wednesday'
elif(day == 3):
    weekday = 'Thursday'
elif(day == 4):
    weekday = 'Friday'
elif(day == 5):
    weekday = 'Saturday'
elif(day == 6):
    weekday = 'Sunday'
    
if os.path.exists('C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Injuries\\injuriestwitter.csv'):
  os.remove("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Injuries\\injuriestwitter.csv")

consumer_key = config.key
consumer_secret = config.secret
access_token = config.token
access_token_secret = config.token_secret


auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth,wait_on_rate_limit=True)


username = 'FantasyLabsNBA'
count = 500
try:     
 # Creation of query method using parameters
 tweets = tweepy.Cursor(api.user_timeline,id=username).items(count)
 
 # Pulling information from tweets iterable object
 tweets_list = [[tweet.created_at, tweet.id, tweet.text] for tweet in tweets]
 
 # Creation of dataframe from tweets list
 # Add or remove columns as you remove tweet information
 tweets_df = pd.DataFrame(tweets_list)
except BaseException as e:
      print('failed on_status,',str(e))
      time.sleep(3)
      
dates = []
for index, row in tweets_df.iterrows():
   dates.append(row[0].date())

df = pd.DataFrame()
df['Date'] = dates
df['ID'] = tweets_df[1]
df['Text'] = tweets_df[2]

df = df[df.Date >= date.today() - timedelta(6)]

playerinjuries = []
for index, row in df.iterrows():
    if((row['Text'].find('out') != -1 
       or row['Text'].find(' unavailable ') != -1 or row['Text'].find('won\'t play') != -1  or row['Text'].find('will not play') != -1 
       or row['Text'].find('will not be available') != -1 or row['Text'].find(' miss ') != -1 or row['Text'].find('doubtful') != -1 or row['Text'].find('unlikely') != -1
       or row['Text'].find('without timetable') != -1 or row['Text'].find('not expected to play') != -1 or row['Text'].find('scratched') != -1
       or row['Text'].find('inactive') != -1 or row['Text'].find('will not start') != -1 or row['Text'].find('won\'t start') != -1 or row['Text'].find('won\'t be available') != -1
       or row['Text'].find('suspended') != -1) and row['Text'].find(weekday) != -1):
                if(len(row['Text'].split('(')) > 1):
                    playerinjuries.append(row['Text'].split('(')[0].replace('Status note: ',''))
                elif(len(row['Text'].split(',')) > 1):
                    for i in range(0, len(row['Text'].split(','))):
                        if(len(row['Text'].split(',')[i].replace('Status note: ','').split(' ')) > 2):
                                playerinjuries.append(row['Text'].split(',')[i].replace('Status note: ','').split(' ')[0] + ' ' 
                              + row['Text'].split(',')[i].replace('Status note: ','').split(' ')[1]
                              + ' ' + row['Text'].split(',')[i].replace('Status note: ','').split(' ')[2])
                        else:
                            playerinjuries.append(row['Text'].split(',')[i].replace('Status note: ','').split(' ')[0] + ' ' 
                              + row['Text'].split(',')[i].replace('Status note: ','').split(' ')[1])
    elif(row['Text'].find('Transaction note:') != -1 or row['Text'].find(' get ') != -1):
        if(row['Text'].find('Transaction note:') != -1 and row['Text'].find('@') == -1):
            text = row['Text'].replace('Transaction note: ','').split(' ')[0] + ' ' +  row['Text'].replace('Transaction note: ','').split(' ')[1]
            playerinjuries.append(text.replace(',',''))
        elif(row['Text'].find(' get ') != -1 and row['Text'].find('@') == -1):
            text = row['Text'].replace('Updated trade summary:','').replace('Trade summary:','').replace('/n','').replace('\n\n', '')
            for i in text.split('-'):
                for j in i.split(','):
                    for k in j.split(' '):
                        if k.strip() not in (' ','','\n\n','/n','get','magic','Celtics','2nd','two','picksJeff','pick','second','Spurs'
                                             ,'round','picks','to','be','waived','by','the','Magic.','Mavs','Heat','Jr.\nCeltics'
                                             ,'https://t.co/Tnq2vSRTAH','Wizards','Jr.','…','https://t.co/NLIrdd9BQo','Clippers','Nuggets'
                                             ,'https://t.co/syrn5ORWa5','Te…','Sixers','https://t.co/O3En8gtT7i'):
                            newk = k.replace(',','').replace('Bulls','').replace('Magic','').replace('Pelicans','').replace('Warriors','').replace('Rockets','').replace('Tracker:','').replace('Hawks','').replace('Thunder','').replace('Knicks','').replace('Blazers','').replace('Kings','').replace('/n','').replace('\n\n', '')
                            if(newk == 'Gafford'):
                                playerinjuries.append('Daniel Gafford')
                            
                            elif(newk == 'Chandler'):
                                playerinjuries.append('Chandler Hutchison')
                            elif(newk == 'Theis'):
                                playerinjuries.append('Daniel Theis')
                            elif(newk == 'Otto'):
                                playerinjuries.append('Otto Porter Jr.')
                            elif(newk == 'Iwundu'):
                                playerinjuries.append('Wes Iwundu')
                            elif(newk == 'Fournier'):
                                playerinjuries.append('Evan Fournier')
                            elif(newk == 'Troy'):
                                playerinjuries.append('Troy Brown')
                            elif(newk == 'Evan'):
                                playerinjuries.append('Evan Fournier')
                            elif(newk == 'Teague'):
                                playerinjuries.append('Jeff Teague')
                            elif(newk == 'Redick'):
                                playerinjuries.append('J.J. Redick')
                            elif(newk == 'Nicolo'):
                                playerinjuries.append('Nicolo Melli')
                            elif(newk == 'James'):
                                playerinjuries.append('James Johnson')
                            elif(newk == 'Marquese'):
                                playerinjuries.append('Marquese Chriss')
                            elif(newk == 'Lalanne'):
                                playerinjuries.append('Cady Lalanne')
                            elif(newk == 'Wagner'):
                                playerinjuries.append('Moe Wagner')
                            elif(newk == 'Victor'):
                                playerinjuries.append('Victor Oladipo')
                            elif(newk == 'Avery'):
                                playerinjuries.append('Avery Bradley')
                            elif(newk == 'Olynyk'):
                                playerinjuries.append('Kelly Olynyk')
                            elif(newk == 'Rajon'):
                                playerinjuries.append('Rajon Rondo')
                            elif(newk == 'Lou'):
                                playerinjuries.append('Lou Williams')
                            elif(newk == 'George'):
                                playerinjuries.append('George Hill')
                            elif(newk == 'Tony'):
                                playerinjuries.append('Tony Bradley')
                            elif(newk == 'Austin'):
                                playerinjuries.append('Austin Rivers')
                            elif(newk == 'Trent'):
                                playerinjuries.append('Gary Trent')
                            elif(newk == 'Rodney'):
                                playerinjuries.append('Rodney Hood')
                            elif(newk == 'Norman'):
                                playerinjuries.append('Norman Powell')
                            elif(newk == 'Nemanja'):
                                playerinjuries.append('Nemanja Bjelica')
                            elif(newk == 'Harkless'):
                                playerinjuries.append('Maurice Harkless')
                            elif(newk == 'Silva'):
                                playerinjuries.append('Chris Silva')
                            elif(newk == 'Aaron'):
                                playerinjuries.append('Aaron Gordon')
                            elif(newk == 'Harris'):
                                playerinjuries.append('Gary Harris')
                            elif(newk == 'RJ'):
                                playerinjuries.append('RJ Hampton')
                            elif(newk == 'Vucevic'):
                                playerinjuries.append('Nikola Vucevic')
                            elif(newk == 'Farouq'):
                                playerinjuries.append('Al Farouq Aminu')
                            elif(newk == 'Wendell'):
                                playerinjuries.append('Wendell Carter')
                            elif(newk == 'JaVale'):
                                playerinjuries.append('JaVale McGee')
                            elif(newk == 'Hartenstein'):
                                playerinjuries.append('Isaiah Hartenstein')
                            elif(newk == 'Cory'):
                                playerinjuries.append('Cory Joseph')
                            elif(newk == 'Delon'):
                                playerinjuries.append('Delon Wright')
                            elif(len(newk.split(' ')) > 1):
                                playerinjuries.append(newk.replace(',',''))
                               
players = []
for p in playerinjuries:
    if(p.split(' ')[0] == ''):
            players.append(p.split(' ')[1].strip() + ' ' + p.split(' ')[2].strip())
    else:
        players.append(p.strip())
        
players = list(OrderedDict.fromkeys(players)) 
        
for p in players:
    if('Lineup note:' in p or 'Updated status note:' in p):
        players.remove(p)

df = pd.DataFrame()
df['Player'] = players
df.to_csv("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Injuries\\injuriestwitter.csv", index = False)

print(str(round((time.time() - start_time) / 60, 2)) + ' Mins')

