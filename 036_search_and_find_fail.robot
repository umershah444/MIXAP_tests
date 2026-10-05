*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create activity
    [Tags]    safari-unverified
    Open Web Application
    Create failed search and find activity    search and find activity    search and find activity instructions

Check for fail message
    [Tags]    safari-unverified
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'validation-pill')]    15s
    ${message}=    Get Text    xpath=//div[contains(@class, 'validation-pill')]
    Should Be Equal As Strings    ${message}    Too bad!
    Close Browser

Create offline activity
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Go Offline
    Create failed search and find activity    search and find activity    search and find activity instructions

Check for fail message offline
    [Tags]    chrome-only    safari-skip:cdp-state
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'validation-pill')]    15s
    ${message}=    Get Text    xpath=//div[contains(@class, 'validation-pill')]
    Should Be Equal As Strings    ${message}    Too bad!
    Close Browser

Create activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Create failed search and find activity    search and find activity Slow3G    search and find activity instructions

Check for fail message - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'validation-pill')]    15s
    ${message}=    Get Text    xpath=//div[contains(@class, 'validation-pill')]
    Should Be Equal As Strings    ${message}    Too bad!
    Close Browser

Create offline activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Go Offline
    Create failed search and find activity    search and find activity Slow3G    search and find activity instructions

Check for fail message offline - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'validation-pill')]    15s
    ${message}=    Get Text    xpath=//div[contains(@class, 'validation-pill')]
    Should Be Equal As Strings    ${message}    Too bad!
    Close Browser
