*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create empty path
    [Tags]    safari-unverified
    Open Web Application
    Create empty path    path_type=Auto-Triggered Path
    Close Browser

Create empty path - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Create empty path    path_type=Auto-Triggered Path
    Close Browser
