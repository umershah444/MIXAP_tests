*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:camera-todo

*** Test Cases ***
### Create blank layers activities, both online and offline.
Create activity
    Open Web Application
    Create basic layers activity    layers activity    layers activity instructions

Create offline activity
    [Tags]    safari-skip:cdp-network
    Open Web Application
    Go Offline
    Create basic layers activity    layers activity    layers activity instructions

Create activity - Slow 3G
    [Tags]    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Create basic layers activity    layers activity Slow3G    layers activity instructions

Create offline activity - Slow 3G
    [Tags]    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Go Offline
    Create basic layers activity    layers activity Slow3G    layers activity instructions
