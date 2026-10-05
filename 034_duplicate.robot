*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create empty augmented activity online
    [Tags]    safari-unverified
    Open Web Application
    Create empty augmented activity    activité numéro 1

Duplicate activity
    [Tags]    safari-unverified
    Duplicate Activity    activité numéro 1
    Sleep    2s

Check duplicated activity
    [Tags]    safari-unverified
    ${rows}=    Get WebElements    xpath=//div[contains(@class, 'activity-card__title')]
    ${count}=   Get Length         ${rows}
    Should Be True    ${count} == 2
    Log    Nombre d'activités: ${count} (devrait être 2)
    Close Browser

Create empty augmented activity online - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Create empty augmented activity    activité numéro 1 Slow3G

Duplicate activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Duplicate Activity    activité numéro 1 Slow3G
    Sleep    2s

Check duplicated activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    ${rows}=    Get WebElements    xpath=//div[contains(@class, 'activity-card__title')]
    ${count}=   Get Length         ${rows}
    Should Be True    ${count} == 2
    Log    Nombre d'activités: ${count} (devrait être 2)
    Close Browser
