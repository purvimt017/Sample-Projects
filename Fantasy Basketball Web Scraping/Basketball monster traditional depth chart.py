# -*- coding: utf-8 -*-
"""
Created on Fri Feb  5 16:13:43 2021

@author: v-mpurvis
"""
# Gets traditional depth chart from basketball monster

base_url = 'https://basketballmonster.com/DepthCharts.aspx'


import pandas as pd
import os 
from bs4 import BeautifulSoup
import requests
from selenium import webdriver
from datetime import date, timedelta
#from openpyxl import load_workbook
#import requestshttps://www.guru99.com/images/image012(1).png
import os
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select


if os.path.exists('C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\DepthCharts\\Basketball_Monster_Traditional.csv'):
  os.remove("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\DepthCharts\\Basketball_Monster_Traditional.csv")


driver = webdriver.Chrome(r"C:\ChromeDriver\chromedriver.exe") 
driver.get(base_url)
delay = 5
actions = WebDriverWait(driver, delay).until(EC.presence_of_element_located((By.ID, 'ContentPlaceHolder1_TraditionalViewRadioButton')))
actions.click()
soup = BeautifulSoup(driver.page_source,'html')
tables = soup.find_all('table')
driver.close()
driver.quit()

starter = []
second = []


for i in range(0,len(tables)):
    table = tables[i]
    #for row in table.find_all('tr'):
     #   for cell in row.find_all(["th","td"]):
      #      print(cell.text)
        
    tab_data = [[cell.text for cell in row.find_all(["th","td"])]
                            for row in table.find_all("tr")]
    
    df = pd.DataFrame(tab_data)
    for index, row in df.iterrows():
        starter.append(row[1])
        second.append(row[2])
        
        
df = pd.DataFrame()
df['Starter'] = starter
df['Second'] = second



df.to_csv('C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\DepthCharts\\Basketball_Monster_Traditional.csv', index = False)


    

