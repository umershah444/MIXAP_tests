*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:camera-detection

*** Test Cases ***
Create activity
    Open Web Application
    Create basic search and find activity    search and find activity    search and find activity instructions

Check for success message
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'validation-pill')]    15s
    ${message}=    Get Text    xpath=//div[contains(@class, 'validation-pill')]
    Should Be Equal As Strings    ${message}    Well done!
    Close Browser

Create offline activity
    Open Web Application
    Go Offline
    Create basic search and find activity    search and find activity    search and find activity instructions

Check for success message offline
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'validation-pill')]    15s
    ${message}=    Get Text    xpath=//div[contains(@class, 'validation-pill')]
    Should Be Equal As Strings    ${message}    Well done!
    Close Browser

Create activity - Slow 3G
    Open Web Application
    Set Network Speed
    Create basic search and find activity    search and find activity Slow3G    search and find activity instructions

Check for success message - Slow 3G
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'validation-pill')]    15s
    ${message}=    Get Text    xpath=//div[contains(@class, 'validation-pill')]
    Should Be Equal As Strings    ${message}    Well done!
    Close Browser

Create offline activity - Slow 3G
    Open Web Application
    Set Network Speed
    Go Offline
    Create basic search and find activity    search and find activity Slow3G    search and find activity instructions

Check for success message offline - Slow 3G
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'validation-pill')]    15s
    ${message}=    Get Text    xpath=//div[contains(@class, 'validation-pill')]
    Should Be Equal As Strings    ${message}    Well done!
    Close Browser
