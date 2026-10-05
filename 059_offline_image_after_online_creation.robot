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
Create activity with image while online
    [Documentation]    Sign up a fresh, randomly-generated account (so this run doesn't add to a shared account's ever-growing history) and create an augmented activity with an image overlay while online.
    Open Web Application
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username}    test_${username}@example.com    password123
    Sleep    15s
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn')]    15s
    ${run_suffix}=    Generate Random String    8    [LETTERS][NUMBERS]
    Set Suite Variable    ${run_suffix}
    Create Activity
    Select Activity Type    Augmented activity
    Next button
    Sleep    2s
    Edit Activity Title    offline image activity ${run_suffix}
    Next button
    Sleep    2s
    Provide Marker Image    Augmented activity    settle=5s
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Add Image To Augmentation
    Sleep    2s
    Wait For Detection Or Log Miss
    Click home button
    Sleep    5s

Go offline and check the image is still there
    [Documentation]    Reopen the activity's editor while still online - "Reopen Activity Editor" reloads the page internally (to give a just-created activity time to show up), and reloading while offline hits Chrome's own network-error page instead of the PWA, so the reopen has to happen before going offline. Only once already inside the editor does it go offline and confirm the image overlay is still rendered. There is no meaningful text value to match on for an image overlay (unlike the text case in 058_offline_text_edit_after_online_creation.robot), so this checks the rendered overlay count instead: 1, for the image added above.
    Reopen Activity Editor    offline image activity ${run_suffix}
    Go Offline
    ${content_count}=    Get Augmentation Content Count
    Should Be Equal As Integers    ${content_count}    1
    Close Browser
