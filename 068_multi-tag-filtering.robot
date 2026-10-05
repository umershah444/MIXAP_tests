*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create first activity with tag one only
    [Tags]    safari-unverified
    Open Web Application
    Create Activity
    Select Activity Type    activity_type=Augmented activity
    Add Tag to Activity    tag numéro 1
    Edit Activity Title    activité numéro 1
    Edit Activity Instructions    instruction relative à l'activité numéro 1
    Next button
    Sleep    2s
    Provide Marker Image    activity_type=Augmented activity
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Next button
    Sleep    2s
    Wait For Detection Or Log Miss
    Click home button

Create second activity with tag two only
    [Tags]    safari-unverified
    Create Activity
    Select Activity Type    activity_type=Augmented activity
    Add Tag to Activity    tag numéro 2
    Edit Activity Title    activité numéro 2
    Edit Activity Instructions    instruction relative à l'activité numéro 2
    Next button
    Sleep    2s
    Provide Marker Image    activity_type=Augmented activity
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Next button
    Sleep    2s
    Wait For Detection Or Log Miss
    Click home button

Create third activity with both tags
    [Tags]    safari-unverified
    Create Activity
    Select Activity Type    activity_type=Augmented activity
    Add Tag to Activity    tag numéro 1
    Add Tag to Activity    tag numéro 2
    Edit Activity Title    activité numéro 3
    Edit Activity Instructions    instruction relative à l'activité numéro 3
    Next button
    Sleep    2s
    Provide Marker Image    activity_type=Augmented activity
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Next button
    Sleep    2s
    Wait For Detection Or Log Miss
    Click home button

Filtering by tag one alone shows activities one and three
    [Documentation]    Baseline: all 3 activities are visible unfiltered. Selecting tag numéro 1 narrows to the 2 activities that carry it (one and three).
    [Tags]    safari-unverified
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${3}    ${activity_number}
    Filter by tag    tag numéro 1
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${2}    ${activity_number}

Selecting a second tag on top of the first
    [Documentation]    "Filter by tag" toggles the chip it's given without touching any other chip's state, so tag numéro 1 is still selected from the previous test case; selecting tag numéro 2 now activates both tags at once. Verified live: multiple selected tags are combined with OR, not AND - all 3 activities show up (any activity carrying at least one of the two selected tags), not just activity three (the only one carrying both).
    [Tags]    safari-unverified
    Filter by tag    tag numéro 2
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${3}    ${activity_number}

Deselecting tag one leaves only tag two active
    [Documentation]    Clicking the tag numéro 1 chip again toggles it back off, leaving only tag numéro 2 selected - this should narrow back down to the 2 activities carrying tag numéro 2 (two and three).
    [Tags]    safari-unverified
    Filter by tag    tag numéro 1
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${2}    ${activity_number}

Deselecting the last tag restores the unfiltered view
    [Documentation]    Toggling tag numéro 2 off too clears the filter entirely, restoring all 3 activities.
    [Tags]    safari-unverified
    Filter by tag    tag numéro 2
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${3}    ${activity_number}
    Close Browser

Create first activity with tag one only - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Create Activity
    Select Activity Type    activity_type=Augmented activity
    Add Tag to Activity    tag numéro 1
    Edit Activity Title    activité numéro 1
    Edit Activity Instructions    instruction relative à l'activité numéro 1
    Next button
    Sleep    2s
    Provide Marker Image    activity_type=Augmented activity
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Next button
    Sleep    2s
    Wait For Detection Or Log Miss
    Click home button

Create second activity with tag two only - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Create Activity
    Select Activity Type    activity_type=Augmented activity
    Add Tag to Activity    tag numéro 2
    Edit Activity Title    activité numéro 2
    Edit Activity Instructions    instruction relative à l'activité numéro 2
    Next button
    Sleep    2s
    Provide Marker Image    activity_type=Augmented activity
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Next button
    Sleep    2s
    Wait For Detection Or Log Miss
    Click home button

Create third activity with both tags - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Create Activity
    Select Activity Type    activity_type=Augmented activity
    Add Tag to Activity    tag numéro 1
    Add Tag to Activity    tag numéro 2
    Edit Activity Title    activité numéro 3
    Edit Activity Instructions    instruction relative à l'activité numéro 3
    Next button
    Sleep    2s
    Provide Marker Image    activity_type=Augmented activity
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Next button
    Sleep    2s
    Wait For Detection Or Log Miss
    Click home button

Filtering by tag one alone shows activities one and three - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${3}    ${activity_number}
    Filter by tag    tag numéro 1
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${2}    ${activity_number}

Selecting a second tag on top of the first - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Filter by tag    tag numéro 2
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${3}    ${activity_number}

Deselecting tag one leaves only tag two active - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Filter by tag    tag numéro 1
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${2}    ${activity_number}

Deselecting the last tag restores the unfiltered view - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Filter by tag    tag numéro 2
    ${activity_number}=    Get Activity Number
    Should Be Equal As Numbers    ${3}    ${activity_number}
    Close Browser
