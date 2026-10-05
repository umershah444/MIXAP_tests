*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Sign up
    [Documentation]    Uses a freshly-generated random username/email instead of a hardcoded shared account, so this run doesn't add to a shared account's ever-growing history (and doesn't collide with a previous run's already-registered email).
    [Tags]    safari-unverified
    Open Web Application
    Maximize Browser Window
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    ${username}    ${username}@example.com    password123
    Wait Until Element Is Visible    xpath=//button[.//span[text()='${username}']]    15s
    Delete Account    password123
    Close Browser

Sign up - Slow 3G
    [Documentation]    Same as above, under throttled network conditions.
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Maximize Browser Window
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    ${username}    ${username}@example.com    password123
    Wait Until Element Is Visible    xpath=//button[.//span[text()='${username}']]    15s
    Delete Account    password123
    Close Browser
