*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
create activity and path
    [Tags]    safari-unverified
    Open Web Application without closing
    Create empty augmented activity    activité numéro 1
    Create empty path

put activity in path
    [Tags]    safari-unverified
    Add Activity to Path    activité numéro 1
    Close Browser

create activity and path - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application without closing
    Set Network Speed
    Create empty augmented activity    activité numéro 1 Slow3G
    Create empty path

put activity in path - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Add Activity to Path    activité numéro 1 Slow3G
    Close Browser
