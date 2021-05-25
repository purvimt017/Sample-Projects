# -*- coding: utf-8 -*-
"""
Created on Sun Apr 18 08:05:01 2021

@author: v-mpurvis
"""

# Gets opponent points per game stats 

base_url = 'https://www.teamrankings.com/nba/stat/opponent-points-per-game'


import pandas as pd
import os 
from bs4 import BeautifulSoup
import requests
from selenium import webdriver
from datetime import date

def teamabbr(team):
    if team.find('Phoenix') != -1:
        team = 'PHX'
    elif team.find('Atlanta')!= -1:
        team = 'ATL'
    elif team.find('Portland')!= -1:
        team = 'POR'
    elif team.find('Milw')!= -1:
       team = 'MIL'
    elif team.find('Chicago')!= -1:
       team = 'CHI'
    elif team.find('Cleve')!= -1:
       team = 'CLE'
    elif team.find('Boston')!= -1:
       team = 'BOS'
    elif team.find('LA Clippers')!= -1:
       team = 'LAC'
    elif team.find('Memp')!= -1:
       team = 'MEM'
    elif team.find('Miami')!= -1:
       team = 'MIA'
    elif team.find('Charlotte')!= -1:
       team = 'CHA'
    elif team.find('Utah')!= -1:
       team = 'UTA'
    elif team.find('Sacr')!= -1:
       team = 'SAC'
    elif team.find('New York')!= -1:
       team = 'NYK'
    elif team.find('LA Lakers')!= -1:
       team = 'LAL'
    elif team.find('Orlando')!= -1:
       team = 'ORL'
    elif team.find('Dallas')!= -1:
       team = 'DAL'
    elif team.find('Brooklyn')!= -1:
       team = 'BKN'
    elif team.find('Denver')!= -1:
       team = 'DEN'
    elif team.find('India')!= -1:
       team = 'IND'
    elif team.find('New Orleans')!= -1:
       team = 'NOP'
    elif team.find('Detroit')!= -1:
       team = 'DET'
    elif team.find('Toronto')!= -1:
       team = 'TOR'
    elif team.find('Houston')!= -1:
        team = 'HOU'
    elif team.find('Phil')!= -1:
        team = 'PHI'
    elif team.find('San Antonio')!= -1:
        team = 'SAS'
    elif team.find('Okla')!= -1:
        team = 'OKC'
    elif team.find('Golden')!= -1:
        team = 'GSW'
    elif team.find('Washington')!= -1:
        team = 'WAS'
    elif team.find('Minne')!= -1:
        team = 'MIN'
    return team

if os.path.exists('C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Opponent Points per game\\Opp_Points_per_Game.csv'):
  os.remove("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Opponent Points per game\\Opp_Points_per_Game.csv")

    
page = requests.get(base_url)
soup = BeautifulSoup(page.content, 'html.parser')
tables = soup.find_all("table")
'''
listhrefs = soup.find_all('a', href=True)
teams = []
for i in listhrefs:
    if(i['href'].find('team') != -1 and i.text not in ['Team Analysis','Schedule Analyzer','Team Lineup Schedule', 'Team Players']):
        teams.append(i.text)
'''
team = []
oppg = []
homeppg = []
awayppg = []


for i in range(0,len(tables)):
    table = tables[i]
    #for row in table.find_all('tr'):
     #   for cell in row.find_all(["th","td"]):
      #      print(cell.text)
        
    tab_data = [[cell.text for cell in row.find_all(["th","td"])]
                            for row in table.find_all("tr")]
    tab_data = tab_data[1:]
    df = pd.DataFrame(tab_data)
    df = df.dropna()
    for index, row in df.iterrows():
        team.append(teamabbr(row[1]))
        oppg.append(row[2])
        homeppg.append(row[5])
        awayppg.append(row[6])
        
        
df = pd.DataFrame()
df["Team"] = team
df['Oppg'] = oppg
df['homeppg'] = homeppg
df['awayppg'] = awayppg

df.to_csv('C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Opponent Points per game\\Opp_Points_per_Game.csv', index = False)