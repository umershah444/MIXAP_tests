*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Variables ***
${path_id}    value

*** Test Cases ***
Create path
    [Tags]    safari-unverified
    Open Web Application without closing
    Maximize Browser Window
    Create empty path    title=path activity    instructions=path activity instructions

Drop path
    [Tags]    safari-unverified
    ${path_id}=    Delete Activity Or Path    path activity
    Set Suite Variable    ${path_id}
    Sleep    5s

Restore path
    [Tags]    safari-unverified
    Restore Activity Or Path    ${path_id}
    Sleep    5s
    Close Browser

Create path - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application without closing
    Set Network Speed
    Maximize Browser Window
    Create empty path    title=path activity Slow3G    instructions=path activity instructions

Drop path - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    ${path_id}=    Delete Activity Or Path    path activity Slow3G
    Set Suite Variable    ${path_id}
    Sleep    5s

Restore path - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Restore Activity Or Path    ${path_id}
    Sleep    5s
    Close Browser
