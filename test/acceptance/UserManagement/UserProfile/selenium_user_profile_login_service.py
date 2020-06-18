from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
import json
from json import load, dump
import time
from eoepca_scim import EOEPCA_Scim, ENDPOINT_AUTH_CLIENT_POST
import logging
logging.basicConfig(format='%(asctime)s %(levelname)-8s %(message)s', level=logging.INFO, datefmt='%Y-%m-%d %H:%M:%S')

def load_config(config_path: str) -> dict:
    """
    Parses and returns the config file

    Returns: dict
    """
    config = {}
    with open(config_path) as j:
        config = load(j)

    return config


def save_config(config_path: str, data: dict):
    """
    Saves updated config file
    """
    with open(config_path, 'w') as j:
        dump(data,j)

y = load_config("config.json")

#Properties for the chrome driver
caps = webdriver.DesiredCapabilities.CHROME.copy()
caps['acceptInsecureCerts'] = True
chrome_options = Options()
chrome_options.add_argument('--headless')
chrome_options.add_argument('--no-sandbox')
chrome_options.add_argument('--disable-dev-shm-usage')

#Set the driver with the properties above
driver = webdriver.Chrome('/usr/local/bin/chromedriver',desired_capabilities=caps, chrome_options=chrome_options)

def user_profile_login(driver, config):
    hostname = config['hostname']
    driver.get(hostname+ '/web_ui')
    print('---------------------------------------------------------------------------------------------')
    try:
        #Sleep until credentials are processed
        element = WebDriverWait(driver, 10)
        logging.info('Main Page Title: ' + driver.title)
        #Matches the login form elemnents
        sub = driver.find_element_by_xpath('//a[@href="/web_ui/login"]')
        sub.click()
        #Wait until the page is loaded
        logging.info('Logging in')
        time.sleep(5)
        print('---------------------------------------------------------------------------------------------')
    finally:
        if driver.title == 'oxAuth - Passport Login':
            #The main page's title matches the expected
            logging.info('Reached Login')
            normal_login(driver, config)
            print('---------------------------------------------------------------------------------------------')
            logging.info('Inside User Profile and logged in')
            time.sleep(5)
            logging.info('Logging out...')
            from_user_profile_logout(driver)   
            print('---------------------------------------------------------------------------------------------')
            logging.info('Success!')
            print('---------------------------------------------------------------------------------------------')
        else:
            #Check if the message was unauthorized
            logging.info('Wrong Page not loaded, is the client running?')



def normal_login(driver, config):
    
    hostname = config['hostname']
    username = config['username']
    password = config['password']
    #Match the gluu instance

    try:
        #Sleep until credentials are processed
        element = WebDriverWait(driver, 4)
        logging.info('Redirected to the Login Service: ' + driver.title)
        #Matches the login form elemnents
        u = driver.find_element_by_id("loginForm:username")
        p = driver.find_element_by_id("loginForm:password")
        submit   = driver.find_element_by_id("loginForm:loginButton")
        #Fill username and password with the user to test
        u.send_keys(username)
        p.send_keys(password)
        submit.click()
        logging.info('Submit admin credentials')
        #Wait until the Authorization is made
        time.sleep(3)
        print('---------------------------------------------------------------------------------------------')
        
    finally:
        logging.info('Redirected to the User Profile Application: '+ driver.title)
        if driver.title == 'EOEPCA User Profile':
            #The main page's title matches the expected
            logging.info('Reached Authentication')
            assert driver.title == 'EOEPCA User Profile'
        else:
            #Check if the message was unauthorized
            fail = driver.find_element_by_xpath('//li[@class="text-center"]')
            logging.info(fail.text)
            logging.info('Wrong User or Password')
        

def from_user_profile_logout(driver):
    print('---------------------------------------------------------------------------------------------')
    try:
        if driver.title == 'EOEPCA User Profile':
            #The main page's title matches the expected
            sub = driver.find_element_by_xpath('//a[@href="/web_ui/logout"]')
            sub.click()
            #Wait until the page is loaded
            time.sleep(3)
        else:
            logging.info('Error in login')

    finally:
        logging.info('Logged out')
        logging.info('Redirected to the Main Page Title: ' + driver.title)
        driver.find_element_by_xpath('//a[@href="/web_ui/login"]')
        



user_profile_login(driver, y)

#normal_login(driver, y)
#git_login(driver,y)
#from_gluu_check_user(driver)

driver.quit()