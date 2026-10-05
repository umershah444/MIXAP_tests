*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:concurrent-browsers

*** Variables ***
${sharecode}    None
${run_suffix}    value

*** Test Cases ***
Create activity and share as first account
    [Documentation]    Account 1 creates an activity and generates a share code for it. Uses a freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    Open Web Application with alias    compte1
    ${username1}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username1}    test_${username1}@example.com    password123
    Sleep    15s
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn')]    15s
    ${run_suffix}=    Generate Random String    8    [LETTERS][NUMBERS]
    Set Suite Variable    ${run_suffix}
    Create empty augmented activity    updated activity ${run_suffix}
    Wait For Activity    activity_title=updated activity ${run_suffix}
    ${sharecode}=    Generate Share Code    activity_title=updated activity ${run_suffix}
    Set Suite Variable    ${sharecode}
    Sleep    5s

Import activity as second account
    [Documentation]    Account 2 imports the activity shared by account 1 using the share code. Uses a second freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    Open Web Application with alias    compte2
    ${username2}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username2}    test_${username2}@example.com    password123
    Import Activity    ${sharecode}
    Sleep    6s

Add text to the activity as first account and resynchronize
    [Documentation]    Back on account 1: reopen the original activity, add a text overlay to it, close the editor and push the update to the cloud. Account 1's browser is deliberately left open (no "Close Browser") - it gets deleted later, in "Verify the text update propagated to the imported copy", only after account 2 has finished depending on it. Deleting it here, before account 2 verifies the propagated update, would risk invalidating the shared activity account 2 still needs to check.
    Switch Browser    compte1
    Reopen Activity Editor    updated activity ${run_suffix}
    Add Text To Augmentation    sample text    click_next=${False}
    Click home button
    Resync Activity
    Close Sync Status Modal
    Sleep    5s

Verify the text update propagated to the imported copy
    [Documentation]    Back on account 2: reopen the imported copy and check that the text added by account 1 after the import is now present. The page was left open since the import, so it needs an explicit reload to pick up account 1's resync - the badge doesn't appear via any live-push, only on next fetch (same reasoning as "Find And Open Activity Menu And Edit"'s reload). Then cleans up both throwaway accounts: account 2 (current session) first, then switches back to account 1 (left open since the previous test case for exactly this reason) to delete it too. "Open Web Application with alias" does not close a pre-existing browser under the same alias, it just re-attaches to it, so leaving "compte2" open here would make the Slow 3G group below silently reuse this already signed-in session instead of getting its own fresh one.
    Switch Browser    compte2
    Reload Page
    Wait Until Element Is Not Visible    xpath=//div[contains(@class, 'loading-blocker__overlay')]    30s
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'activity-card__status-badge activity-card__status-badge--updated-recent')]    60s
    Delete Account    password123
    Close Browser
    Switch Browser    compte1
    Delete Account    password123
    Close Browser

Create activity and share as first account - Slow 3G
    [Documentation]    Account 1 creates an activity and generates a share code for it, under throttled network conditions. Uses a freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    [Tags]    safari-skip:cdp-network
    Open Web Application with alias    compte1
    Set Network Speed
    ${username1}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username1}    test_${username1}@example.com    password123
    Sleep    15s
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn')]    15s
    ${run_suffix}=    Generate Random String    8    [LETTERS][NUMBERS]
    Set Suite Variable    ${run_suffix}
    Create empty augmented activity    updated activity ${run_suffix}
    Wait For Activity    activity_title=updated activity ${run_suffix}
    ${sharecode}=    Generate Share Code    activity_title=updated activity ${run_suffix}
    Set Suite Variable    ${sharecode}
    Sleep    5s

Import activity as second account - Slow 3G
    [Documentation]    Account 2 imports the activity shared by account 1 using the share code, under throttled network conditions. Uses a second freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    [Tags]    safari-skip:cdp-network
    Open Web Application with alias    compte2
    Set Network Speed
    ${username2}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username2}    test_${username2}@example.com    password123
    Import Activity    ${sharecode}
    Sleep    6s

Add text to the activity as first account and resynchronize - Slow 3G
    [Documentation]    Back on account 1: reopen the original activity, add a text overlay to it, close the editor and push the update to the cloud. Account 1's browser is deliberately left open (no "Close Browser") - it gets deleted later, in "Verify the text update propagated to the imported copy - Slow 3G", only after account 2 has finished depending on it.
    [Tags]    safari-skip:cdp-state
    Switch Browser    compte1
    Reopen Activity Editor    updated activity ${run_suffix}
    Add Text To Augmentation    sample text    click_next=${False}
    Click home button
    Resync Activity
    Close Sync Status Modal
    Sleep    5s

Verify the text update propagated to the imported copy - Slow 3G
    [Documentation]    Back on account 2: reopen the imported copy and check that the text added by account 1 after the import is now present. The page was left open since the import, so it needs an explicit reload to pick up account 1's resync - the badge doesn't appear via any live-push, only on next fetch. Then cleans up both throwaway accounts: account 2 first, then account 1 (left open since the previous test case).
    [Tags]    safari-skip:cdp-state
    Switch Browser    compte2
    Reload Page
    Wait Until Element Is Not Visible    xpath=//div[contains(@class, 'loading-blocker__overlay')]    30s
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'activity-card__status-badge activity-card__status-badge--updated-recent')]    60s
    Delete Account    password123
    Close Browser
    Switch Browser    compte1
    Delete Account    password123
    Close Browser
