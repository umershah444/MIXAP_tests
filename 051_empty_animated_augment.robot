*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create empty augmented activity
    [Tags]    safari-unverified
    Open Web Application
    Create Activity

Select Type
    [Tags]    safari-unverified
    Select Activity Type    Augmented activity

Edit activity details
    [Tags]    safari-unverified
    Edit Activity Title    activité numéro 1
    Edit Activity Instructions    instruction relative à l'activité numéro 1

Use animated image
    [Tags]    safari-unverified
    Next button
    Sleep    2s
    Use template image
    Sleep    2s

display activity
    [Tags]    safari-unverified
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Next button
    Sleep    2s
    Wait For Detection Or Log Miss
    Click home button
    Close Browser

Create empty augmented activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Create Activity

Select Type - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Select Activity Type    Augmented activity

Edit activity details - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Edit Activity Title    activité numéro 1 Slow3G
    Edit Activity Instructions    instruction relative à l'activité numéro 1

Use animated image - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Next button
    Sleep    2s
    Use template image
    Sleep    2s

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