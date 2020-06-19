*** Settings ***
Library  SeleniumLibrary
Suite Teardown  Close All Browsers


*** Test Cases ***

Do Google Search
  Open Browser Search Page
  Search For Term  fred
  Search For Term  bob

Do Google Search Headless
  Open Headless Search Page
  Search For Term  burt
  Search For Term  larry

*** Keywords ***

Open Browser Search Page
  Open Browser  http://www.google.co.uk  Chrome  alias=google
  Title Should Be  Google

Open Headless Search Page
  Open Browser  http://www.google.co.uk  HeadlessChrome  alias=headless
  Title Should Be  Google

Search For Term
  [Arguments]  ${search_term}
  Enter Search Term  ${search_term}
  Submit Search Query
  Search Results Should Be Displayed  ${search_term}

Enter Search Term
  [Arguments]  ${search_term}
  Input Text  q  ${search_term}

Submit Search Query
  Press Keys  q  RETURN

Search Results Should Be Displayed
  [Arguments]  ${search_term}
  Title Should Be  ${search_term} - Google Search

