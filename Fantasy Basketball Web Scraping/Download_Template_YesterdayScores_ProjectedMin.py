# -*- coding: utf-8 -*-
"""
Created on Thu Jan 28 09:23:10 2021

@author: v-mpurvis
"""

#import pandas as pd
from selenium import webdriver
from datetime import date, timedelta
#from openpyxl import load_workbook
#import requestshttps://www.guru99.com/images/image012(1).png
import os
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.chrome.options import Options 
from bs4 import BeautifulSoup
import requests
import config

chrome_options = Options()  
chrome_options.add_argument("--headless")  

today = date.today()
yesterday = today - timedelta(days = 1) 

datestring = yesterday.strftime("%Y-%m-%d")
todayds = today.strftime("%Y-%m-%d")
todayds2 = today.strftime("%Y_%m_%d")

#download yesterday
driver = webdriver.Chrome(r"C:\ChromeDriver\chromedriver.exe") 
driver.get('https://www.fantasycruncher.com/lineup-rewind/draftkings/NBA/' + datestring)
delay = 5
login_box = WebDriverWait(driver, delay).until(EC.presence_of_element_located((By.ID, 'user_email')))
login_box.send_keys(config.username)
pass_box = driver.find_element_by_id('user_password')
pass_box.send_keys(config.password)
login_button = driver.find_element_by_id('submit')
login_button.click()
driver.get('https://www.fantasycruncher.com/lineup-rewind/draftkings/NBA/' + datestring)
gamefilter = WebDriverWait(driver, delay).until(EC.presence_of_element_located((By.ID, 'game-filter-menu')))
gamefilter.click()
gamefilterslate = driver.find_element_by_class_name("game-filter-all")
gamefilterslate.click()
actions = WebDriverWait(driver, delay).until(EC.presence_of_element_located((By.ID, 'table-actions')))
actions.click()
download_button = driver.find_element_by_xpath("/html/body/div[3]/div[1]/div[1]/div/div[2]/div[3]/div[4]") #
download_button.click()
#download today
driver.get('https://www.fantasycruncher.com/lineup-rewind/draftkings/NBA/' + todayds)
gamefilter = WebDriverWait(driver, delay).until(EC.presence_of_element_located((By.ID, 'game-filter-menu')))
gamefilter.click()
gamefilterslate = driver.find_element_by_class_name("game-filter-all")
gamefilterslate.click()
'''
gamefilterslate = driver.find_element_by_class_name("game-filter-slate-select")
gamefilterslate.click()
gamefilterslate.find_elements_by_tag_name('option')[1].click()
'''
actions = WebDriverWait(driver, delay).until(EC.presence_of_element_located((By.ID, 'table-actions')))
actions.click()
download_button = driver.find_element_by_xpath("/html/body/div[3]/div[1]/div[1]/div/div[2]/div[3]/div[4]") #
download_button.click()

driver.get('https://basketballmonster.com/login.aspx')
delay = 5
login_box = WebDriverWait(driver, delay).until(EC.presence_of_element_located((By.ID, 'UsernameTB')))
login_box.send_keys('aceventura')
pass_box = driver.find_element_by_id('PasswordTB')
pass_box.send_keys('sdasda29!')
login_button = driver.find_element_by_id('LoginButton')
login_button.click()
driver.get('https://basketballmonster.com/dailyprojections.aspx')
delay = 5
date_box = WebDriverWait(driver, delay).until(EC.presence_of_element_located((By.ID, 'GAMEDATE')))
date_box.send_keys(today.strftime('%m/%d/%Y'))
date_box.submit()
import time
time.sleep(2)
export_button = WebDriverWait(driver, delay).until(EC.presence_of_element_located((By.NAME, 'EXCELBUTTON')))
export_button.click()

time.sleep(5)
driver.close()
driver.quit()

if os.path.exists("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Original Files\\draftkings_NBA_" + datestring + "_players.csv"):
        os.remove("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Original Files\\draftkings_NBA_" + datestring + "_players.csv")
if os.path.exists("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\TodayDVP\\draftkings_NBA_" + todayds + "_players.csv"):
        os.remove("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\TodayDVP\\draftkings_NBA_" + todayds + "_players.csv")
if os.path.exists("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Projected Minutes\\Export_" + todayds2 + ".xls"):
        os.remove("C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Projected Minutes\\Export_" + todayds2 + ".xls")
os.rename("C:\\Users\\v-mpurvis\\Downloads\\draftkings_NBA_" + datestring + "_players.csv", "C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Original Files\\draftkings_NBA_" + datestring + "_players.csv")
os.rename("C:\\Users\\v-mpurvis\\Downloads\\draftkings_NBA_" + todayds + "_players.csv", "C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\TodayDVP\\draftkings_NBA_" + todayds + "_players.csv")
os.rename("C:\\Users\\v-mpurvis\\Downloads\\BBM_Daily.xls", "C:\\Users\\v-mpurvis\\OneDrive\\Personal Files\\Fantasy Basketball\\Projected Minutes\\Export_" + todayds2 + ".xls")
time.sleep(5)