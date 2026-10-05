*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:camera-todo

*** Test Cases ***
### Create blank layers activities, and add multiple layers, both online and offline.
Create activity
    Open Web Application
    Maximize Browser Window
    Create basic layers activity without validation    layers activity    layers activity instructions
    Add multiple layers
    Furnish layers with content
    Check that all layers are present and contain the expected content

Create offline activity
    [Tags]    safari-skip:cdp-network
    Open Web Application
    Go Offline
    Create basic layers activity without validation    layers activity    layers activity instructions
    Add multiple layers
    Furnish layers with content
    Check that all layers are present and contain the expected content

Create activity - Slow 3G
    [Tags]    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Maximize Browser Window
    Create basic layers activity without validation    layers activity Slow3G    layers activity instructions
    Add multiple layers
    Furnish layers with content
    Check that all layers are present and contain the expected content

Create offline activity - Slow 3G
    [Tags]    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Go Offline
    Create basic layers activity without validation    layers activity Slow3G    layers activity instructions
    Add multiple layers
    Furnish layers with content
    Check that all layers are present and contain the expected content
