*** Settings ***
Resource  ADES.resource
Library  SeleniumLibrary

*** Variables ***

${URL}=  https://eoepca-dev.deimos-space.com
${USER}=  admin
${PWD}=  admin_Abcd1234#
${CLIENT_ID}=  be7d5fe9-4e60-4a84-a814-507e25687068
${CLIENT_SECRET}=  a1a46378-eabc-4776-b95b-096f1dc215db
${chromedriver}=  /usr/local/bin/chromedriver
*** Test Cases ***

Login Test
    Open Browser  https://google.com  Chrome
    ${dc}=  Evaluate  sys.modules['selenium.webdriver'].DesiredCapabilities.CHROME  sys, selenium.webdriver
    Set To Dictionary  ${dc}  acceptInsecureCerts  ${True}
    ${chrome_options}=  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    Call Method  ${chrome_options}  add_argument  --headless
    Call Method  ${chrome_options}  add_argument  --disable-dev-shm-usage
    Call Method  ${chrome_options}  add_argument  --no-startup-window
    Call Method  ${chrome_options}  add_argument  --no-sandbox

    Create Webdriver  Chrome  executable_path=${chromedriver}  desired_capabilities=${dc}  chrome_options=${chrome_options}
    Log to console  hmm aqui llega
    Open Browser  https://google.com  Chrome

*** Keywords ***
