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

*** Keywords ***
Add Audio To Augmentation Via Upload And Finalize
    [Documentation]    Add an audio overlay by uploading a local file, then finalize the wizard step. Mirrors the "Select the audio tool and upload a file" flow from 041_audio_tool.robot (selectors confirmed live there: the "auras__popbar" popup and the hidden "basic_file" input), which itself never finalizes since it only exercises the tool in isolation - the trailing "Next button" click here is added for this test's own needs, to reach a fully published, reopenable activity.
    Click Element    xpath=//button[contains(@title, 'Audio')]
    Sleep    2s
    Click Element    xpath=//div[contains(@class, 'auras__popbar')]
    Choose File Robust    id=basic_file    ${EXECDIR}/assets/moo1.wav
    Sleep    2s
    Click Element    xpath=//div[contains(@class, 'auras__popbar')]
    Sleep    5s
    Next button

*** Test Cases ***
Create activity with audio while online
    [Documentation]    Sign up a fresh, randomly-generated account (so this run doesn't add to a shared account's ever-growing history) and create an augmented activity with an uploaded audio overlay while online.
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
    Edit Activity Title    offline audio activity ${run_suffix}
    Next button
    Sleep    2s
    Provide Marker Image    Augmented activity    settle=5s
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Add Audio To Augmentation Via Upload And Finalize
    Wait For Detection Or Log Miss
    Click home button
    Sleep    5s

Go offline and check the audio is still there
    [Documentation]    Reopen the activity's editor while still online - "Reopen Activity Editor" reloads the page internally (to give a just-created activity time to show up), and reloading while offline hits Chrome's own network-error page instead of the PWA, so the reopen has to happen before going offline. Only once already inside the editor does it go offline and confirm the audio overlay is still rendered. There is no meaningful text value to match on for an audio overlay (unlike the text case in 058_offline_text_edit_after_online_creation.robot), so this checks the rendered overlay count instead: 1, for the audio added above.
    Reopen Activity Editor    offline audio activity ${run_suffix}
    Go Offline
    ${content_count}=    Get Augmentation Content Count
    Should Be Equal As Integers    ${content_count}    1
    Close Browser
