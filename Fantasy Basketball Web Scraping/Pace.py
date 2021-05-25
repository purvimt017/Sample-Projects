# -*- coding: utf-8 -*-
"""
Created on Fri Feb  5 16:13:43 2021

@author: v-mpurvis
"""
# Gets team pace data 

base_url = 'http://www.espn.com/nba/hollinger/teamstats'

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


if os.path.exists('C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Pace\\pace.csv'):
  os.remove('C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Pace\\pace.csv')
  

page = requests.get(base_url)
soup = BeautifulSoup(page.content, 'html.parser')
tables = soup.find_all("table")

Team = []
Pace = []
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
        Team.append(row[1])
        Pace.append(row[2])
        
       # players.append(df[0].iloc[0])
df = pd.DataFrame()
df['Team'] = Team
df['Pace'] = Pace

df = df.drop(0, axis = 0)
abbr = []
for index, row in df.iterrows():
    t = row['Team']
    if(t=='Brooklyn'):
        abbr.append('BKN')
    elif(t=='LA Clippers'):
        abbr.append('LAC')
    elif(t=='Utah'):
        abbr.append('UTA')
    elif(t=='Milwaukee'):
        abbr.append('MIL')
    elif(t=='Denver'):
        abbr.append('DEN')
    elif(t=='Portland'):
        abbr.append('POR')
    elif(t=='New Orleans'):
        abbr.append('NOP')
    elif(t=='Phoenix'):
        abbr.append('PHX')
    elif(t=='Sacramento'):
        abbr.append('SAC')
    elif(t=='Atlanta'):
        abbr.append('ATL')
    elif(t=='Dallas'):
        abbr.append('DAL')
    elif(t=='Boston'):
        abbr.append('BOS')
    elif(t=='Philadelphia'):
        abbr.append('PHI')
    elif(t=='Toronto'):
        abbr.append('TOR')
    elif(t=='Charlotte'):
        abbr.append('CHA')
    elif(t=='Indiana'):
        abbr.append('IND')
    elif(t=='Chicago'):
        abbr.append('CHI')
    elif(t=='LA Lakers'):
        abbr.append('LAL')
    elif(t=='Memphis'):
        abbr.append('MEM')
    elif(t=='Washington'):
        abbr.append('WAS')
    elif(t=='San Antonio'):
        abbr.append('SAS')
    elif(t=='Golden State'):
        abbr.append('GSW')
    elif(t=='New York'):
        abbr.append('NYK')
    elif(t=='Miami'):
        abbr.append('MIA')
    elif(t=='Detroit'):
        abbr.append('DET')
    elif(t=='Minnesota'):
        abbr.append('MIN')
    elif(t=='Orlando'):
        abbr.append('ORL')
    elif(t=='Oklahoma City'):
        abbr.append('OKC')
    elif(t=='Houston'):
        abbr.append('HOU')
    elif(t=='Cleveland'):
        abbr.append('CLE')
    else:
        abbr.append(row['Team'])
df['ABR'] = abbr

df.to_csv("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Pace\\pace.csv", index = False)

print(str(round((time.time() - start_time) / 60, 2)) + ' Mins')
