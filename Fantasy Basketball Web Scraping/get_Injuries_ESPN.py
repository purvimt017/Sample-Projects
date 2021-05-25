# -*- coding: utf-8 -*-
"""
Created on Fri Feb  5 16:13:43 2021

@author: v-mpurvis
"""
# Downloads latest injury news from ESPN

base_url = 'https://www.espn.com/nba/injuries'

import pandas as pd
import os 
from bs4 import BeautifulSoup
import requests
from datetime import date
import time 

start_time = time.time()

today = date.today()

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


if os.path.exists('C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Injuries\\injuries.csv'):
  os.remove("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Injuries\\injuries.csv")
  

page = requests.get(base_url)
soup = BeautifulSoup(page.content, 'html.parser')
tables = soup.find_all("table")

players = []
pos = []
dates = []
status = []
comment = []
for i in range(0,len(tables)):
    table = tables[i]
    #for row in table.find_all('tr'):
     #   for cell in row.find_all(["th","td"]):
      #      print(cell.text)
        
    tab_data = [[cell.text for cell in row.find_all(["th","td"])]
                            for row in table.find_all("tr")]
    tab_data = tab_data[1:]
    df = pd.DataFrame(tab_data)
    for index, row in df.iterrows():
        players.append(row[0])
        pos.append(row[1])
        dates.append(row[2])
        status.append(row[3])
        comment.append(row[4])
       # players.append(df[0].iloc[0])
df = pd.DataFrame()
df['NAME'] = players
df['POS'] = pos
df['DATE'] = dates
df['STATUS'] = status
df['COMMENT'] = comment

    
playerinjuries = []
playerpos = []

for index, row in df.iterrows():
    try:
        if(row['COMMENT'].find('questionable') == -1
           and row['COMMENT'].find('probable') == -1
           ):
            playerinjuries.append(row['NAME'])
            playerpos.append(row['POS'])
    except AttributeError:
        pass
        
df = pd.DataFrame()
df['Player'] = playerinjuries
df['Pos'] = playerpos
df.to_csv("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Injuries\\injuries.csv", index = False)

print(str(round((time.time() - start_time) / 60, 2)) + ' Mins')
