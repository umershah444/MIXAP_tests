*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Sign in
    [Documentation]    Uses a freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    [Tags]    safari-unverified
    Open Web Application
    Maximize Browser Window
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username}    test_${username}@example.com    password123
    Wait Until Element Is Visible    xpath=//button[.//span[text()='test_${username}']]    15s

Create activity
    [Tags]    safari-unverified
    Create empty augmented activity   activité numéro 1

Synchronize activity
    [Tags]    safari-unverified
    Synchronize Activity
    Close Sync Status Modal
    Delete Account    password123
    Close Browser

Sign in - Slow 3G
    [Documentation]    Uses a freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Maximize Browser Window
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username}    test_${username}@example.com    password123
    Wait Until Element Is Visible    xpath=//button[.//span[text()='test_${username}']]    15s

Create activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Create empty augmented activity   activité numéro 1 Slow3G

Synchronize activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Synchronize Activity
    Close Sync Status Modal
    Delete Account    password123
    Close Browser
