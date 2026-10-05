*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create two activities and a guided path
    [Documentation]    Creates two activities and a Guided Path containing both, in order, so the path player's step navigation can be verified.
    [Tags]    safari-unverified
    Open Web Application without closing
    Maximize Browser Window
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    ${username}    test_${username}@example.com    password123
    Create empty augmented activity    activity one
    ${id1}=    Get Card Data Id    activity one
    Create empty augmented activity    activity two
    ${id2}=    Get Card Data Id    activity two
    Create empty path    title=guided path test    path_type=Guided Path
    ${path_id}=    Get Card Data Id    guided path test
    Set Suite Variable    ${path_id}
    Add Activity to Path By Id    ${id1}    ${path_id}
    Add Activity to Path By Id    ${id2}    ${path_id}

Launching the path starts on its first activity
    [Documentation]    The path player opens on step 1: the "previous" control is disabled since there is nothing before it.
    [Tags]    safari-unverified
    Play Path    guided path test
    Sleep    5s
    Path Player Previous Button Should Be Disabled

Advancing moves to the next activity and enables "previous"
    [Documentation]    Clicking "next" moves to step 2, which now has something before it.
    [Tags]    safari-unverified
    Go To Next Activity In Path Player
    Path Player Previous Button Should Be Enabled

Going back returns to the first activity
    [Documentation]    Clicking "previous" returns to step 1, where "previous" is disabled again.
    [Tags]    safari-unverified
    Go To Previous Activity In Path Player
    Path Player Previous Button Should Be Disabled
    Exit Path Player
    Delete Account    password123
    Close Browser

Create two activities and a guided path - Slow 3G
    [Documentation]    Creates two activities and a Guided Path containing both, in order, so the path player's step navigation can be verified, under throttled network conditions.
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application without closing
    Set Network Speed
    Maximize Browser Window
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    ${username}    test_${username}@example.com    password123
    Create empty augmented activity    activity one
    ${id1}=    Get Card Data Id    activity one
    Create empty augmented activity    activity two
    ${id2}=    Get Card Data Id    activity two
    Create empty path    title=guided path test    path_type=Guided Path
    ${path_id}=    Get Card Data Id    guided path test
    Set Suite Variable    ${path_id}
    Add Activity to Path By Id    ${id1}    ${path_id}
    Add Activity to Path By Id    ${id2}    ${path_id}

Launching the path starts on its first activity - Slow 3G
    [Documentation]    The path player opens on step 1: the "previous" control is disabled since there is nothing before it.
    [Tags]    chrome-only    safari-skip:cdp-state
    Play Path    guided path test
    Sleep    5s
    Path Player Previous Button Should Be Disabled

Advancing moves to the next activity and enables "previous" - Slow 3G
    [Documentation]    Clicking "next" moves to step 2, which now has something before it.
    [Tags]    chrome-only    safari-skip:cdp-state
    Go To Next Activity In Path Player
    Path Player Previous Button Should Be Enabled

Going back returns to the first activity - Slow 3G
    [Documentation]    Clicking "previous" returns to step 1, where "previous" is disabled again.
    [Tags]    chrome-only    safari-skip:cdp-state
    Go To Previous Activity In Path Player
    Path Player Previous Button Should Be Disabled
    Exit Path Player
    Delete Account    password123
    Close Browser
