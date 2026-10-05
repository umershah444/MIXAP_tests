*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Library    Collections
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Variables ***
${sharecode}    None

*** Test Cases ***
Create 8 activities and share path
    [Documentation]    Uses a freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    [Tags]    safari-unverified
    Open Web Application
    ${username1}=    Generate Random String    10    [LETTERS][NUMBERS]
    Set Suite Variable    ${username1}
    Sign Up    test_${username1}    test_${username1}@example.com    password123
    Sleep    15s
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn')]    15s
    Wait Until Element Is Not Visible    xpath=//div[contains(@class, 'loading-blocker__overlay')]    30s
    ${run_suffix}=    Generate Random String    8    [LETTERS][NUMBERS]
    Set Suite Variable    ${run_suffix}

    # Only the first activity goes through the full creation wizard (title, camera snap,
    # validation...). The other 7 are obtained by duplicating the previous one: the app
    # appends " (copy)" to the source title on each duplication, so chaining the duplicates
    # (each one duplicated from the previous copy, not from the original) keeps every title
    # unique without needing to rename anything. Each card's unique data-id is captured right
    # after it's created/duplicated, so every step from here on targets cards by id instead of
    # by title text - immune to duplicate or stale-data titles elsewhere on the page.
    ${activity_ids}=    Create List
    ${current_title}=    Set Variable    activité numéro 1 ${run_suffix}
    Create empty augmented activity    ${current_title}
    ${current_id}=    Get Card Data Id    ${current_title}
    Append To List    ${activity_ids}    ${current_id}

    FOR    ${i}    IN RANGE    1    8
        Duplicate Activity    ${current_title}
        ${current_title}=    Set Variable    ${current_title} (copy)
        ${current_id}=    Get Card Data Id    ${current_title}
        Append To List    ${activity_ids}    ${current_id}
    END

    ${path_title}=    Set Variable    parcours numéro 1 ${run_suffix}
    Create empty path    ${path_title}
    ${path_id}=    Get Card Data Id    ${path_title}

    FOR    ${activity_id}    IN    @{activity_ids}
        Add Activity to Path By Id    ${activity_id}    ${path_id}
    END
    Sleep    10s

    ${sharecode}=    Generate Share Code With Id    ${path_id}
    Set Suite Variable    ${sharecode}

    Close Browser

Import activity with share code
    [Documentation]    Uses a second freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    [Tags]    safari-unverified
    Open Web Application
    ${username2}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username2}    test_${username2}@example.com    password123
    Import Activity    ${sharecode}
    Sleep    20s

# No "Close Browser" between this test case and the previous one: read-only imported
# activities are tied to the browser session/machine, not the signed-in account (confirmed
# app behavior). Closing the browser here would delete the imported path before it can be
# launched below.
Launch imported activity
    [Documentation]    Launches the imported activity, then cleans up both throwaway accounts: account 2 (current session) first, then account 1 - reopened and signed back into specifically because deleting the sharing account any earlier (before account 2 finished importing/launching) would risk invalidating the share code or the imported copy.
    [Tags]    safari-unverified
    Click Element    xpath=//button[contains(@class, 'activity-card__title-arrow-button')]
    Sleep    2s
    Wait For Detection Or Log Miss
    Exit Path Player
    Delete Account    password123
    Close Browser
    Open Web Application
    Sign In    test_${username1}@example.com    password123
    Delete Account    password123
    Close Browser

Create 8 activities and share path - Slow 3G
    [Documentation]    Uses a freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    ${username1}=    Generate Random String    10    [LETTERS][NUMBERS]
    Set Suite Variable    ${username1}
    Sign Up    test_${username1}    test_${username1}@example.com    password123
    Sleep    15s
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn')]    15s
    Wait Until Element Is Not Visible    xpath=//div[contains(@class, 'loading-blocker__overlay')]    30s
    ${run_suffix}=    Generate Random String    8    [LETTERS][NUMBERS]
    Set Suite Variable    ${run_suffix}

    # Only the first activity goes through the full creation wizard (title, camera snap,
    # validation...). The other 7 are obtained by duplicating the previous one: the app
    # appends " (copy)" to the source title on each duplication, so chaining the duplicates
    # (each one duplicated from the previous copy, not from the original) keeps every title
    # unique without needing to rename anything. Each card's unique data-id is captured right
    # after it's created/duplicated, so every step from here on targets cards by id instead of
    # by title text - immune to duplicate or stale-data titles elsewhere on the page.
    ${activity_ids}=    Create List
    ${current_title}=    Set Variable    activité numéro 1 ${run_suffix}
    Create empty augmented activity    ${current_title}
    ${current_id}=    Get Card Data Id    ${current_title}
    Append To List    ${activity_ids}    ${current_id}

    FOR    ${i}    IN RANGE    1    8
        Duplicate Activity    ${current_title}
        ${current_title}=    Set Variable    ${current_title} (copy)
        ${current_id}=    Get Card Data Id    ${current_title}
        Append To List    ${activity_ids}    ${current_id}
    END

    ${path_title}=    Set Variable    parcours numéro 1 ${run_suffix}
    Create empty path    ${path_title}
    ${path_id}=    Get Card Data Id    ${path_title}

    FOR    ${activity_id}    IN    @{activity_ids}
        Add Activity to Path By Id    ${activity_id}    ${path_id}
    END
    Sleep    10s

    ${sharecode}=    Generate Share Code With Id    ${path_id}
    Set Suite Variable    ${sharecode}

    Close Browser

Import activity with share code - Slow 3G
    [Documentation]    Uses a second freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    ${username2}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username2}    test_${username2}@example.com    password123
    Import Activity    ${sharecode}
    Sleep    20s

# No "Close Browser" between this test case and the previous one: read-only imported
# activities are tied to the browser session/machine, not the signed-in account (confirmed
# app behavior). Closing the browser here would delete the imported path before it can be
# launched below.
Launch imported activity - Slow 3G
    [Documentation]    Launches the imported activity, then cleans up both throwaway accounts: account 2 (current session) first, then account 1 - reopened and signed back into specifically because deleting the sharing account any earlier (before account 2 finished importing/launching) would risk invalidating the share code or the imported copy.
    [Tags]    chrome-only    safari-skip:cdp-state
    Click Element    xpath=//button[contains(@class, 'activity-card__title-arrow-button')]
    Sleep    2s
    Wait For Detection Or Log Miss
    Exit Path Player
    Delete Account    password123
    Close Browser
    Open Web Application
    Sign In    test_${username1}@example.com    password123
    Delete Account    password123
    Close Browser
