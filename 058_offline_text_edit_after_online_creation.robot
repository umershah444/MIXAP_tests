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
Create activity with text while online
    [Documentation]    Sign up a fresh, randomly-generated account (so this run doesn't add to a shared account's ever-growing history) and create an augmented activity with a text overlay while online.
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
    Edit Activity Title    offline text activity ${run_suffix}
    Next button
    Sleep    2s
    Provide Marker Image    Augmented activity    settle=5s
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Add Text To Augmentation    texte en ligne
    Wait For Detection Or Log Miss
    Click home button
    Sleep    5s

Go offline and check the text is still there
    [Documentation]    Reopen the activity's editor while still online - "Reopen Activity Editor" reloads the page internally (to give a just-created activity time to show up), and reloading while offline hits Chrome's own network-error page instead of the PWA, so the reopen has to happen before going offline. Only once already inside the editor does it go offline and confirm the text overlay added while online is still rendered. Checked via "Augmentation Should Contain Text" (DOM presence) rather than reopening the text tool to read it back - clicking "Text" again adds a brand new overlay instead of reselecting the existing one (confirmed live: it left two overlapping "Edit your text..." textareas behind).
    Reopen Activity Editor    offline text activity ${run_suffix}
    Go Offline
    Augmentation Should Contain Text    texte en ligne

Edit the existing text while still offline
    [Documentation]    Still offline: click directly on the rendered text overlay itself (the same "auras__html-container" element "Augmentation Should Contain Text" just found) to reopen it for editing, rather than the "Text" toolbar button - a screenshot from a failed run showed the existing overlay is auto-selected with its own floating formatting toolbar as soon as the canvas is entered, and the bottom "Text" button is for adding a brand new element, which does nothing useful (and leaves no textarea behind) while one is already selected. Confirms the textarea opens pre-filled with the current value, then replaces it and confirms the new value took.
    Click Element    xpath=//*[contains(@class, 'auras__html-container') and contains(., 'texte en ligne')]
    Wait Until Element Is Visible    xpath=//textarea[@placeholder='Edit your text...']    15s
    ${current_text}=    Get Value    xpath=//textarea[@placeholder='Edit your text...']
    Should Be Equal As Strings    ${current_text}    texte en ligne
    Clear Element Text    xpath=//textarea[@placeholder='Edit your text...']
    Input Text    xpath=//textarea[@placeholder='Edit your text...']    texte modifié hors-ligne
    Sleep    2s
    ${updated_text}=    Get Value    xpath=//textarea[@placeholder='Edit your text...']
    Should Be Equal As Strings    ${updated_text}    texte modifié hors-ligne
    Click home button
    Close Browser
