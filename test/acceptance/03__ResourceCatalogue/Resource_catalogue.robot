*** Settings ***
Documentation  Tests for the Data Access endpoints
Library  RequestsLibrary
Library  Collections
Library  ../../client/DemoClient.py  ${UM_BASE_URL}
Library  CatalogueServiceWeb.py  ${CATALOGUE_BASE_URL}/csw

Suite Setup  Suite Setup
Suite Teardown  Suite Teardown


*** Variables ***
${USERNAME}=  ${USER_A_NAME}
${PASSWORD}=  ${USER_A_PASSWORD}
${ID_TOKEN}=
${ACCESS_TOKEN}=
${FILENAME}=  S2B_MSIL1C_20210402T095029_N0300_R079_T33SVB_20210402T121737
${WORKSPACE_CATALOGUE}=  https://resource-catalogue.${USER_PREFIX}-${USERNAME}.${PUBLIC_HOSTNAME}

*** Test Cases ***
Get Operations Information
  Get Csw Operations

Get Records Information
  Get Csw Records Filtered

Workspace Catalogue
  Reload Catalogue  ${WORKSPACE_CATALOGUE}/csw
  Get Csw Records

Opensearch
  Load Opensearch  ${CATALOGUE_BASE_URL}/opensearch
  Search Opensearch
  Search Requests

*** Keywords ***
Suite Setup
  Init ID Token  ${USERNAME}  ${PASSWORD}

Suite Teardown
  Client Save State
  Catalogue Save State

Init ID Token
  [Arguments]  ${username}  ${password}
  ${id_token}=  Get ID Token  ${username}  ${password}
  Should Be True  $id_token is not None
  Set Suite Variable  ${ID_TOKEN}  ${id_token}

Get Csw Operations
  ${operations}=  Get Operations
  ${cnt}=    Get length    ${operations}
  should be equal as numbers  ${cnt}  6
  ${constraints}=  Get Constraints  GetRecords
  ${cnt}=    Get length    ${constraints}
  should be equal as numbers  ${cnt}  3

Get Csw Records Filtered
  ${results}=  Get Results  10
  ${returned}=  Get From Dictionary  ${results}  returned
  should be equal as numbers  ${returned}  10
  ${records}=  Get Records Filtered
  ${returned}=  Get From Dictionary  ${records}  ${FILENAME}.SAFE
  Should Be True  $returned is not None
  ${wms_endpoint}=  Get Record Link
  Should Be True  $wms_endpoint is not None
  ${contents}=  Get Map  ${wms_endpoint}
  Should Be True  $contents is not None
  ${check}=  Check Array  ${contents}  ${FILENAME}.SAFE
  Should Be True  $check
  ${record}  Get Record  ${FILENAME}.SAFE
  should be equal as strings  ${record.title}  ${FILENAME}.SAFE

Get Csw Records
  ${results}=  Get Results  10
  ${returned}=  Get From Dictionary  ${results}  returned
  should be equal as numbers  ${returned}  2
  ${records}=  Get Records
  ${returned}=  Get From Dictionary  ${records}  ${FILENAME}
  Should Be True  $returned is not None
  ${record}  Get Record  ${FILENAME}
  should be equal as strings  ${record.title}  ${FILENAME}

Search Opensearch
  ${results}=  Open Search
  ${length}=    Get length    ${results}
  should be equal as numbers  ${length}  10
  ${results2}=  Open Search  {"{eo:cloudCover?}": {"value": "]20"}}
  ${length2}=    Get length    ${results2}
  should be equal as numbers  ${length2}  10

Search Requests
  ${results}=  Search With Requests  ${CATALOGUE_BASE_URL}/opensearch/?mode=opensearch&service=CSW&version=3.0.0&request=GetRecords&elementsetname=full&resulttype=results&typenames=csw:Record
  ${results}=  Search With Requests  ${CATALOGUE_BASE_URL}/opensearch/?mode=opensearch&service=CSW&version=3.0.0&request=GetRecords&elementsetname=full&resulttype=results&typenames=csw:Record&eo:parentIdentifier=S2MSI2A
  ${results}=  Search With Requests  ${WORKSPACE_CATALOGUE}/opensearch/?mode=opensearch&service=CSW&version=3.0.0&request=GetRecords&elementsetname=full&resulttype=results&typenames=csw:Record