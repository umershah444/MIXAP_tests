*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Variables ***
${sharecode}    None

*** Test Cases ***
Create activity and share
    [Documentation]    Uses a freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    [Tags]    safari-unverified
    Open Web Application
    ${username1}=    Generate Random String    10    [LETTERS][NUMBERS]
    Set Suite Variable    ${username1}
    Sign Up    test_${username1}    test_${username1}@example.com    password123
    Sleep    15s
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn')]    15s
    Create empty augmented activity    activité numéro 1
    ${sharecode}=    Generate Share Code
    Set Suite Variable    ${sharecode}
    Close Browser

Import activity with share code
    [Documentation]    Uses a second freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    [Tags]    safari-unverified
    Open Web Application
    ${username2}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username2}    test_${username2}@example.com    password123
    Import Activity    ${sharecode}
    Sleep    2s

# No "Close Browser" between this test case and the previous one: read-only imported
# activities are tied to the browser session/machine, not the signed-in account (confirmed
# app behavior). Closing the browser here would delete the imported activity before it can
# be launched below.
Launch imported activity
    [Documentation]    Launches the imported activity, then cleans up both throwaway accounts: account 2 (current session) first, then account 1 - reopened and signed back into specifically because deleting the sharing account any earlier (before account 2 finished importing/launching) would risk invalidating the share code or the imported copy.
    [Tags]    safari-unverified
    Click Element    xpath=//button[contains(@class, 'activity-card__title-arrow-button')]
    Sleep    2s
    Wait For Detection Or Log Miss
    Exit Path Player
    Delete Account    password123
    Close Browser
    Open Web Application
    Sign In    test_${username1}@example.com    password123
    Delete Account    password123
    Close Browser

Create activity and share - Slow 3G
    [Documentation]    Uses a freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    ${username1}=    Generate Random String    10    [LETTERS][NUMBERS]
    Set Suite Variable    ${username1}
    Sign Up    test_${username1}    test_${username1}@example.com    password123
    Sleep    15s
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn')]    15s
    Create empty augmented activity    activité numéro 1 Slow3G
    ${sharecode}=    Generate Share Code
    Set Suite Variable    ${sharecode}
    Close Browser

Import activity with share code - Slow 3G
    [Documentation]    Uses a second freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    ${username2}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username2}    test_${username2}@example.com    password123
    Import Activity    ${sharecode}
    Sleep    2s

# No "Close Browser" between this test case and the previous one: read-only imported
# activities are tied to the browser session/machine, not the signed-in account (confirmed
# app behavior). Closing the browser here would delete the imported activity before it can
# be launched below.
Launch imported activity - Slow 3G
    [Documentation]    Launches the imported activity, then cleans up both throwaway accounts: account 2 (current session) first, then account 1 - reopened and signed back into specifically because deleting the sharing account any earlier (before account 2 finished importing/launching) would risk invalidating the share code or the imported copy.
    [Tags]    chrome-only    safari-skip:cdp-state
    Click Element    xpath=//button[contains(@class, 'activity-card__title-arrow-button')]
    Sleep    2s
    Wait For Detection Or Log Miss
    Exit Path Player
    Delete Account    password123
    Close Browser
    Open Web Application
    Sign In    test_${username1}@example.com    password123
    Delete Account    password123
    Close Browser
