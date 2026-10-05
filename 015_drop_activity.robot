*** Settings ***
Library    SeleniumLibrary
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
create an activity
    [Tags]    safari-unverified
    Open Web Application without closing
    Create empty augmented activity    activité numéro 1

drop activity
    [Tags]    safari-unverified
    Delete Activity Or Path    activité numéro 1
    Sleep    5s
    Close Browser

create an activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application without closing
    Set Network Speed
    Create empty augmented activity    activité numéro 1 Slow3G

drop activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Delete Activity Or Path    activité numéro 1 Slow3G
    Sleep    5s
    Close Browser
