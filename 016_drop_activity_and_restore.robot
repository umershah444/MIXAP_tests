*** Settings ***
Library    SeleniumLibrary
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Variables ***
${card_id}    value

*** Test Cases ***
create an activity
    [Tags]    safari-unverified
    Open Web Application without closing
    Create empty augmented activity    activité numéro 1

drop activity
    [Tags]    safari-unverified
    ${card_id}=    Delete Activity Or Path    activité numéro 1
    Set Suite Variable    ${card_id}
    Sleep    5s

restore activity
    [Tags]    safari-unverified
    Restore Activity Or Path    ${card_id}
    Sleep    5s
    Close Browser

create an activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application without closing
    Set Network Speed
    Create empty augmented activity    activité numéro 1 Slow3G

drop activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    ${card_id}=    Delete Activity Or Path    activité numéro 1 Slow3G
    Set Suite Variable    ${card_id}
    Sleep    5s

restore activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Restore Activity Or Path    ${card_id}
    Sleep    5s
    Close Browser
