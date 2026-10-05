*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:offline-suite

*** Test Cases ***
Create empty augmented activity offline
    Open Web Application
    Go Offline
    Create empty augmented activity    activité numéro 1

Duplicate activity
    Duplicate Activity    activité numéro 1
    Sleep    2s

Check duplicated activity
    ${rows}=    Get WebElements    xpath=//div[contains(@class, 'activity-card__title')]
    ${count}=   Get Length         ${rows}
    Should Be True    ${count} == 2
    Log    Nombre d'activités: ${count} (devrait être 2)
    Close Browser
