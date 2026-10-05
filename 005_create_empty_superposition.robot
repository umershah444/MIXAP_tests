*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create empty layers activity
    [Tags]    safari-unverified
    Open Web Application
    Create Activity

Select Type
    [Tags]    safari-unverified
    Select Activity Type    Information layers

Edit activity details
    [Tags]    safari-unverified
    Edit Activity Title    activité numéro 1
    Edit Activity Instructions    instruction relative à l'activité numéro 1

Snap the landscape
    [Tags]    chrome-only    safari-skip:camera-todo
    Next button
    Sleep    2s
    Provide Marker Image    Information layers

display activity
    [Tags]    chrome-only    safari-skip:session-of-skipped
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Next button
    Sleep    2s
    Wait For Detection Or Log Miss
    Click home button
    Close Browser

Create empty layers activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Create Activity

Select Type - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Select Activity Type    Information layers

Edit activity details - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Edit Activity Title    activité numéro 1 Slow3G
    Edit Activity Instructions    instruction relative à l'activité numéro 1

Snap the landscape - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state    safari-skip:camera-todo
    Next button
    Sleep    2s
    Provide Marker Image    Information layers

display activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Next button
    Sleep    2s
    Wait For Detection Or Log Miss
    Click home button
    Close Browser
