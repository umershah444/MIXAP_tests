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

Snap the background
    [Tags]    safari-unverified
    Next button
    Provide Marker Image    Augmented activity
    Sleep    2s
    Next button
    Sleep    2s
    Validation button

Add sheet to the augmentation
    [Tags]    safari-unverified
    Add Sheet To Augmentation

display augmented activity
    [Tags]    safari-unverified
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

Snap the background - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Next button
    Provide Marker Image    Augmented activity
    Sleep    2s
    Next button
    Sleep    2s
    Validation button

Add sheet to the augmentation - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Add Sheet To Augmentation

display augmented activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Sleep    2s
    Wait For Detection Or Log Miss
    Click home button
    Close Browser
