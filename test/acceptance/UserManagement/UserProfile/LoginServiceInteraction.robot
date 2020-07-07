*** Settings ***

Library  SeleniumLibrary
Library  Process
Library  OperatingSystem
Library  Collections

*** Variables ***

*** Test Cases ***

Log in to the User Profile through the Login Service
  UMA Get Data from Config File
  ${chrome_options} =  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
  Call Method  ${chrome_options}  add_argument  headless
  Call Method  ${chrome_options}  add_argument  disable-gpu
  Call Method  ${chrome_options}  add_argument  disable-dev-shm-usage
  Call Method  ${chrome_options}  add_argument  no-startup-window
  Call Method  ${chrome_options}  add_argument  no-sandbox
  Call Method  ${chrome_options}  add_argument  ignore-certificate-errors
  ${options}=  Call Method  ${chrome_options}  to_capabilities      
  Open Browser  ${URL}  browser=chrome  desired_capabilities=${options}
  Set Browser Implicit Wait  5
  ${title}=  Get Title
  BuiltIn.Run Keyword If  "${title}"=="EOEPCA User Profile"  LoginService Call Log in Button
  LoginService Fill Credentials
  ${title}=  Get Title
  BuiltIn.Run Keyword If  "${title}"=="oxAuth"  LoginService Allow User
  BuiltIn.Run Keyword If  "${title}"=="oxAuth - Passport Login"  LoginService Fill Credentials
  LoginService Call Log out Button

*** Keywords ***

UMA Get Data from Config File
  ${data}=  OperatingSystem.Get File  ./config.json
  ${json}=  Evaluate  json.loads('''${data}''')  json
  ${URL}=  Get From Dictionary  ${json}  hostname
  ${USER}=  Get From Dictionary  ${json}  username
  ${PWD}=  Get From Dictionary  ${json}  password
  Set Global Variable  ${URL}
  Set Global Variable  ${USER} 
  Set Global Variable  ${PWD}

LoginService Allow User
  Title Should Be  oxAuth
  Click Link  xpath=//a[@id="authorizeForm:allowButton"]
  Set Browser Implicit Wait  5
  #Capture Page Screenshot  

LoginService Call Log in Button
  Title Should Be  EOEPCA User Profile
  Click Link    xpath=//a[@href="/web_ui/login"]
  Set Browser Implicit Wait  5
  #Capture Page Screenshot

LoginService Fill Credentials
  Title Should Be  oxAuth - Passport Login
  Input Text  id=loginForm:username  admin
  Input Password  id=loginForm:password  admin_Abcd1234#
  Click Button  id=loginForm:loginButton
  Set Browser Implicit Wait  10

LoginService Call Log out Button
  Title Should Be  EOEPCA User Profile
  Click Link    xpath=//a[@href="/web_ui/logout"]
  Set Browser Implicit Wait  5
