*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:offline-suite

*** Variables ***
${run_suffix}    value

*** Test Cases ***
Create activity and share as first account
    [Documentation]    Signs up a fresh account, goes offline right after sign-in, creates an activity while offline, then goes back online and explicitly syncs it before signing out. Uses a freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history. The wait for the sync button's "dirty" class to clear after "Synchronize Activity" is deliberate, not redundant: confirmed live (isolated repro, including a variant with no offline step at all) that "Synchronize Activity"'s own "wait for uploaded" check shares the exact same gap as "Resync Activity" (see 054_update_propagation_offline.robot's docstring for the full explanation) - the "uploaded" class appears as soon as the activity has EVER been cloud-synced, independent of the separate "dirty" modifier that marks content still not actually persisted server-side. Without waiting for "dirty" to clear here, "Sign Out" can fire before the real upload finishes, and the activity is then genuinely missing account-side for the next test case to find - not a fetch/timing issue on the read side.
    Open Web Application
    ${username1}=    Generate Random String    10    [LETTERS][NUMBERS]
    Set Suite Variable    ${username1}
    Sign Up    test_${username1}    test_${username1}@example.com    password123
    Sleep    15s
    Go Offline
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn')]    15s
    ${run_suffix}=    Generate Random String    8    [LETTERS][NUMBERS]
    Set Suite Variable    ${run_suffix}
    Create empty augmented activity    empty activity ${run_suffix}
    Go Online
    Sleep    2s
    Synchronize Activity    empty activity ${run_suffix}
    Wait Until Element Is Not Visible    xpath=//h3[contains(@class, 'activity-card') and text()='empty activity ${run_suffix}']/ancestor::div[3]//button[contains(@class, 'activity-card__action-button--sync') and contains(@class, 'dirty')]    90s
    Close Sync Status Modal
    Sign Out
    Close Browser

Open Account back to see if activity is there
    [Documentation]    Signs back into the same account in a brand new browser session and confirms the activity that was created offline, then explicitly synced once back online, is really present in the cloud - not just in the original browser's local state. KNOWN INTERMITTENT APP BEHAVIOR (confirmed live across 5 isolated repro runs, including a variant with no offline step at all): the very first cloud replication for a brand-new account+device pair that has never signed in before does not reliably surface a just-synced activity even after waiting - one run found it within a minute, the rest never did even after waiting a full 3 minutes on the write side already having confirmed its own "dirty" flag cleared. This is not a fetch/timeout tuning problem (waiting longer did not help) and not specific to the offline-creation angle this file is named for (reproduced identically for a fully-online create+sync too) - it points at a genuine gap in the app's initial cloud replication for a fresh account/device, not a test script issue. Kept at a bounded, reasonable wait rather than an ever-growing one, so a real regression here still fails loudly instead of being disguised by a wait long enough to always pass.
    Open Web Application
    Sign In    test_${username1}@example.com    password123
    Wait For Activity    empty activity ${run_suffix}    60s
    Close Browser
