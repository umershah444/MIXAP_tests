*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create activity with tag
    [Tags]    safari-unverified
    Open Web Application
    Create Activity
    Select Activity Type    activity_type=Augmented activity
    Add Tag to Activity    tag numéro 1

Edit activity details
    [Tags]    safari-unverified
    Edit Activity Title    activité numéro 1
    Edit Activity Instructions    instruction relative à l'activité numéro 1

Snap the background
    [Tags]    safari-unverified
    Next button
    Sleep    2s
    Provide Marker Image    activity_type=Augmented activity

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

Create empty activity and filter
    [Tags]    safari-unverified
    Create empty augmented activity    activité numéro 2
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${2}    ${activity_number}
    Filter by tag    tag numéro 1
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${1}    ${activity_number}
    Close Browser

Create activity with tag - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Create Activity
    Select Activity Type    activity_type=Augmented activity
    Add Tag to Activity    tag numéro 1

Edit activity details - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Edit Activity Title    activité numéro 1 Slow3G
    Edit Activity Instructions    instruction relative à l'activité numéro 1

Snap the background - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Next button
    Sleep    2s
    Provide Marker Image    activity_type=Augmented activity

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

Create empty activity and filter - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Create empty augmented activity    activité numéro 2 Slow3G
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${2}    ${activity_number}
    Filter by tag    tag numéro 1
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${1}    ${activity_number}
    Close Browser