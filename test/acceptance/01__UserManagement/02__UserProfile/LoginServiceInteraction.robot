*** Settings ***

Library  SeleniumLibrary
Library  Process
Library  OperatingSystem
Library  Collections

*** Variables ***
${USER}=  admin
${PWD}=  admin_Abcd1234#

#User Data
${USER_NAME}=  User
${FIRST_NAME}=  User
${DISPLAY_NAME}=  User
${LAST_NAME}=  User
${EMAIL}=  acceptance@test.com
${PASSWORD}=  defaultPWD
*** Test Cases ***

Log in to the User Profile through the Login Service
  ${chrome_options} =  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
  Call Method  ${chrome_options}  add_argument  headless
  Call Method  ${chrome_options}  add_argument  disable-gpu
  Call Method  ${chrome_options}  add_argument  disable-dev-shm-usage
  Call Method  ${chrome_options}  add_argument  no-startup-window
  Call Method  ${chrome_options}  add_argument  no-sandbox
  Call Method  ${chrome_options}  add_argument  ignore-certificate-errors
  ${options}=  Call Method  ${chrome_options}  to_capabilities      
  Open Browser  ${UM_BASE_URL}/web_ui  browser=chrome  desired_capabilities=${options}
  Set Browser Implicit Wait  5
  ${title}=  Get Title
  BuiltIn.Run Keyword If  "${title}"=="EOEPCA User Profile"  LoginService Call Log in Button
  LoginService Fill Credentials
  ${title}=  Get Title
  BuiltIn.Run Keyword If  "${title}"=="oxAuth"  LoginService Allow User
  BuiltIn.Run Keyword If  "${title}"=="oxAuth - Passport Login"  LoginService Fill Credentials
  LoginService Call Log out Button

Add Two Users to Gluu
  ${chrome_options} =  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
  Call Method  ${chrome_options}  add_argument  headless
  Call Method  ${chrome_options}  add_argument  disable-gpu
  Call Method  ${chrome_options}  add_argument  disable-dev-shm-usage
  Call Method  ${chrome_options}  add_argument  no-startup-window
  Call Method  ${chrome_options}  add_argument  no-sandbox
  Call Method  ${chrome_options}  add_argument  ignore-certificate-errors
  ${options}=  Call Method  ${chrome_options}  to_capabilities      
  Open Browser  ${UM_BASE_URL}  browser=chrome  desired_capabilities=${options}
  Set Browser Implicit Wait  5
  ${title}=  Get Title
  LoginService Fill Credentials Gluu  ${USER}  ${PWD}
  LoginService Go to Users
  ${title}=  Get Title
  LoginService Add Person  ${USER_NAME}A  ${FIRST_NAME}A  ${DISPLAY_NAME}A  ${LAST_NAME}A  A${EMAIL}  ${PASSWORD}
  ${title}=  Get Title
  Set Browser Implicit Wait  20
  LoginService Go TabUser
  LoginService Add Person  ${USER_NAME}B  ${FIRST_NAME}B  ${DISPLAY_NAME}B  ${LAST_NAME}B  B${EMAIL}  ${PASSWORD}
  

*** Keywords ***
LoginService Go TabUser
  Click Element  xpath=//li[@id="subMenuLinkUsers2"]

LoginService Add Person
  [Arguments]  ${user_name}  ${first_name}  ${display_name}  ${last_name}  ${email}  ${password}
  Click Element  xpath=//a[@class="addPerson btn btn-primary"]
  Click Element  xpath=//input[@id="PForm:L:0:IL:0:D:custId_text_"]
  Input Text  xpath=//input[@id="PForm:L:0:IL:0:D:custId_text_"]  ${user_name}
  Click Element  xpath=//input[@id="PForm:L:1:IL:0:D:custId_text_"]
  Input Text  xpath=//input[@id="PForm:L:1:IL:0:D:custId_text_"]  ${first_name}
  Click Element  xpath=//input[@id="PForm:L:2:IL:0:D:custId_text_"]
  Input Text  xpath=//input[@id="PForm:L:2:IL:0:D:custId_text_"]  ${display_name}
  Click Element  xpath=//input[@id="PForm:L:3:IL:0:D:custId_text_"]
  Input Text  xpath=//input[@id="PForm:L:3:IL:0:D:custId_text_"]  ${last_name}
  Click Element  xpath=//input[@id="PForm:L:4:IL:0:D:Email"]
  Input Text  xpath=//input[@id="PForm:L:4:IL:0:D:Email"]  ${email}
  Click Element  xpath=//input[@id="PForm:L:5:IL:0:P:custpasswordId"]
  Input Password  xpath=//input[@id="PForm:L:5:IL:0:P:custpasswordId"]  ${password}
  Click Element  xpath=//input[@id="PForm:L:5:IL:0:j_idt244:custconfirmpasswordId"]
  Input Password  xpath=//input[@id="PForm:L:5:IL:0:j_idt244:custconfirmpasswordId"]  ${password}
  Set Browser Implicit Wait  20
  Click Element  xpath=//input[@id="PForm:L:4:IL:0:D:Email"]
  Click Element  xpath=//button[@name="PForm:j_idt306"]
  Set Browser Implicit Wait  2
  Set Browser Implicit Wait  2

LoginService Update Person
  [Arguments]  ${mod}  ${user_name}
  Click Element  xpath=//input[@id="PForm:L:0:IL:0:D:custId_text_"]
  Input Text  xpath=//input[@id="PForm:L:0:IL:0:D:custId_text_"]  ${mod}  False
  Click Element  xpath=//input[@id="PForm:L:1:IL:0:D:custId_text_"]
  Click Element  xpath=//input[@name="PForm:L:1:IL:0:D:custId_text_"]
  Click Element  xpath=//li[@id="subMenuLinkUsers2"]
  Click Element  xpath=//input[@id="j_idt128:searchPattern:searchPatternId"]
  Input Text  xpath=//input[@id="j_idt128:searchPattern:searchPatternId"]  ${user_name}
  Click Element  xpath=//input[@name="j_idt128:searchPattern:j_idt129"]
  Set Browser Implicit Wait  20
  ${tex}=  Get Text  xpath=//a[starts-with(@href, "/identity/person/update/")]
  Should Be Equal  ${tex}  ${mod}${user_name}

LoginService Delete Person
  Click Link  xpath=//a[starts-with(@href, "/identity/person/update/")]
  Click Element  xpath=//input[@name="j_idt125:j_idt218"]
  Set Browser Implicit Wait  20
  Click Element  xpath=//input[@name="deleteConfirmation:j_idt257"]

LoginService Find Person
  [Arguments]  ${user_name}
  Set Browser Implicit Wait  10
  Click Element  xpath=//li[@id="subMenuLinkUsers2"]
  Set Browser Implicit Wait  10
  Click Element  xpath=//input[@id="j_idt128:searchPattern:searchPatternId"]
  Input Text  xpath=//input[@id="j_idt128:searchPattern:searchPatternId"]  ${user_name}
  Click Element  xpath=//input[@name="j_idt128:searchPattern:j_idt129"]
  Set Browser Implicit Wait  20
  Click Link  xpath=//a[starts-with(@href, "/identity/person/update/")]

LoginService Go to Users
  Click Element  xpath=//li[@id="menuUsers"]
  Set Browser Implicit Wait  2
  Click Element  xpath=//li[@id="subMenuLinkUsers2"]

LoginService Fill Credentials Gluu
  [Arguments]  ${user}  ${pwd}
  Input Text  id=loginForm:username  ${user}
  Input Password  id=loginForm:password  ${pwd}
  Click Button  id=loginForm:loginButton
  Set Browser Implicit Wait  10
#em

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
