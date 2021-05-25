# -*- coding: utf-8 -*-
"""
Created on Fri Feb  5 16:13:43 2021

@author: v-mpurvis
"""
# Gets Lineup Rotations from Basketball Monster

base_url = 'https://basketballmonster.com/DepthCharts.aspx'


import pandas as pd
import os 
from bs4 import BeautifulSoup
import requests
from selenium import webdriver
from datetime import date


if os.path.exists('C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\DepthCharts\\Basketball_Monster_Rotation.csv'):
  os.remove("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\DepthCharts\\Basketball_Monster_Rotation.csv")

    
page = requests.get(base_url)
soup = BeautifulSoup(page.content, 'html.parser')
tables = soup.find_all("table")

bigsmall = []
pos = []
name = []
ind = []


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
        pos.append(row[0])
        if(row[0] in ['PG','SG','SF']):
            bigsmall.append('Small')
        elif(row[0] in ['PF','C']):
            bigsmall.append('Big')
        na = row[1].split('(')[0]
        name.append(na.strip())
        if(index < 6):
            ind.append(index + 1)
        else:
            ind.append(index)
        
        
df = pd.DataFrame()
df['Pos'] = pos
df['BigSmall'] = bigsmall
df['Name'] = name
df['Depth'] = ind


df.to_csv('C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\DepthCharts\\Basketball_Monster_Rotation.csv', index = False)


    

