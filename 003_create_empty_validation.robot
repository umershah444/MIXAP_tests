*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create empty Search and Find activity
    [Tags]    safari-unverified
    Open Web Application
    Create Activity

Select Type
    [Tags]    safari-unverified
    Select Activity Type    Search and Find

Edit activity details
    [Tags]    safari-unverified
    Edit Activity Title    activité numéro 1
    Edit Activity Instructions    instruction relative à l'activité numéro 1

Snap the landscape
    [Tags]    safari-unverified
    Next button
    Sleep    2s
    Provide Marker Image    Search and Find

display activity
    [Tags]    safari-unverified
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Next button
    Sleep    5s
    Wait For Detection Or Log Miss
    Click home button
    Close Browser

Create empty Search and Find activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Create Activity

Select Type - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Select Activity Type    Search and Find

Edit activity details - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Edit Activity Title    activité numéro 1 Slow3G
    Edit Activity Instructions    instruction relative à l'activité numéro 1

Snap the landscape - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Next button
    Sleep    2s
    Provide Marker Image    Search and Find

display activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Next button
    Sleep    5s
    Wait For Detection Or Log Miss
    Click home button
    Close Browser
