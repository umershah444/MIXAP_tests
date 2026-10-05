*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create a path and an activity
    [Tags]    safari-unverified
    Open Web Application
    Create empty path
    Create empty augmented activity    activité numéro 1

Filter activities and paths
    [Tags]    safari-unverified
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__filter-btn')]    15s
    Click Element    xpath=//button[contains(@class, 'home__filter-btn')]

    Wait Until Element Is Visible    xpath=//input[@value='activity']/ancestor::label    15s
    Click Element    xpath=//input[@value='activity']/ancestor::label

    ## Check that only activities are displayed
    ${rows}=    Get WebElements    xpath=//div[contains(@class, 'activity-card__title')]
    ${count}=   Get Length         ${rows}
    Should Be True    ${count} == 1
    Log    Nombre d'activités: ${count} (devrait être 1)

    Wait Until Element Is Visible    xpath=//input[@value='path']/ancestor::label    15s
    Click Element    xpath=//input[@value='path']/ancestor::label

    ## Check that only paths are displayed
    ${rows}=    Get WebElements    xpath=//div[contains(@class, 'activity-card__title')]
    ${count}=   Get Length         ${rows}
    Should Be True    ${count} == 1
    Log    Nombre de chemins: ${count} (devrait être 1)

Create a path and an activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Create empty path
    Create empty augmented activity    activité numéro 1 Slow3G

Filter activities and paths - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__filter-btn')]    15s
    Click Element    xpath=//button[contains(@class, 'home__filter-btn')]

    Wait Until Element Is Visible    xpath=//input[@value='activity']/ancestor::label    15s
    Click Element    xpath=//input[@value='activity']/ancestor::label

    ## Check that only activities are displayed
    ${rows}=    Get WebElements    xpath=//div[contains(@class, 'activity-card__title')]
    ${count}=   Get Length         ${rows}
    Should Be True    ${count} == 1
    Log    Nombre d'activités: ${count} (devrait être 1)

    Wait Until Element Is Visible    xpath=//input[@value='path']/ancestor::label    15s
    Click Element    xpath=//input[@value='path']/ancestor::label

    ## Check that only paths are displayed
    ${rows}=    Get WebElements    xpath=//div[contains(@class, 'activity-card__title')]
    ${count}=   Get Length         ${rows}
    Should Be True    ${count} == 1
    Log    Nombre de chemins: ${count} (devrait être 1)
