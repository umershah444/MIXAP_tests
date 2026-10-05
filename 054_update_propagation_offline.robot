*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:concurrent-browsers    safari-skip:offline-suite

*** Variables ***
${sharecode}    None
${run_suffix}    value

*** Test Cases ***
Create activity and share as first account
    [Documentation]    Account 1 creates an activity and generates a share code for it. Uses a freshly signed-up, randomly-generated account instead of one of the shared test accounts, so this run doesn't add to their ever-growing history.
    Open Web Application with alias    compte1
    ${username1}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username1}    test_${username1}@example.com    password123
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn')]    15s
    ${run_suffix}=    Generate Random String    8    [LETTERS][NUMBERS]
    Set Suite Variable    ${run_suffix}
    Go Offline
    Create empty augmented activity    updated activity ${run_suffix}
    Wait For Activity    activity_title=updated activity ${run_suffix}
    Go Online
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
    Go Offline

Add text to the activity as first account and resynchronize
    [Documentation]    Back on account 1: reopen the original activity, add a text overlay to it while offline, close the editor and click resync, then go back online and wait for the deferred push to actually complete before closing the browser. "Resync Activity"'s own "wait for uploaded" check is not enough here: per ActivityCard.tsx, the sync button carries the "uploaded" class whenever the card has EVER been cloud-synced before (true here - it was already synced once to generate the share code), independent of a separate "dirty" modifier that marks unpushed local changes - so clicking resync while genuinely offline satisfies that wait vacuously without the edit ever reaching the server. Confirmed live (054's own "Verify the text update propagated..." case) that closing the browser only 5s after going back online, with nothing checking the push actually completed, can lose the update entirely - the account 2 badge assertion below then times out because the server genuinely never received it, not because of any fetch/reload issue on account 2's side. Waiting here for the "dirty" class to clear closes that gap - the wait needs at least 60s: per the app's "useAutoActivitySync(delayMs: number = 60_000)" (useAutoActivitySync.ts), a dirty activity's auto-sync only fires after a 60s debounce from its last edit (a shorter 10s "startup delay" only applies to an activity that was already dirty before a page *reload*, which does not happen here), confirmed live via an initial 30s wait timing out.
    Switch Browser    compte1
    Reopen Activity Editor    updated activity ${run_suffix}
    Go Offline
    Add Text To Augmentation    sample text    click_next=${False}
    Click home button
    Resync Activity
    Sleep    5s
    Go Online
    Wait Until Element Is Not Visible    xpath=//button[contains(@class, 'activity-card__action-button--sync') and contains(@class, 'dirty')]    90s
    Sleep    5s
    Close Browser

Verify the text update propagated to the imported copy when it goes back online
    [Documentation]    Back on account 2: reopen the imported copy and check that the text added by account 1 after the import is now present. The page was left open since the import, so it needs an explicit reload to pick up account 1's resync - the badge doesn't appear via any live-push, only on next fetch (same reasoning as "Find And Open Activity Menu And Edit"'s reload). Closes the browser afterwards - "Open Web Application with alias" does not close a pre-existing browser under the same alias, it just re-attaches to it, so leaving "compte2" open here would make the Slow 3G group below silently reuse this already signed-in session instead of getting its own fresh one.
    Switch Browser    compte2
    Go Online
    Reload Page
    Wait Until Element Is Not Visible    xpath=//div[contains(@class, 'loading-blocker__overlay')]    30s
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'activity-card__status-badge activity-card__status-badge--updated-recent')]    60s
    Close Browser