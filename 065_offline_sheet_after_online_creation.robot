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
Create activity with sheet while online
    [Documentation]    Sign up a fresh, randomly-generated account (so this run doesn't add to a shared account's ever-growing history) and create an augmented activity with a note/sheet overlay while online.
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
    Edit Activity Title    offline sheet activity ${run_suffix}
    Next button
    Sleep    2s
    Provide Marker Image    Augmented activity
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Add Sheet To Augmentation    note en ligne
    Sleep    2s
    Wait For Detection Or Log Miss
    Click home button
    Sleep    5s

Go offline and check the sheet text is still there
    [Documentation]    Reopen the activity's editor while still online - "Reopen Activity Editor" reloads the page internally (to give a just-created activity time to show up), and reloading while offline hits Chrome's own network-error page instead of the PWA, so the reopen has to happen before going offline. Only once already inside the editor does it go offline and confirm the sheet's text is still there. Same as with text overlays, the toolbar's "Note" button only adds a new overlay rather than reselecting the existing one, so this clicks directly on the rendered overlay (the "auras__html-container" element) to open its editor drawer and read the text back.
    Reopen Activity Editor    offline sheet activity ${run_suffix}
    Go Offline
    Click Element    xpath=(//*[contains(@class, 'auras__html-container')])[last()]
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'tiptap ProseMirror')]    15s
    ${current_text}=    Get Text    xpath=//div[contains(@class, 'tiptap ProseMirror')]
    Should Be Equal As Strings    ${current_text}    note en ligne

Edit the existing sheet text while still offline
    [Documentation]    Still offline: replace the note's text via "Input Text" (its "clear()" works fine on this contenteditable, confirmed live) and confirm the new value took, proving the note is fully editable offline too, not just readable.
    Click Element    xpath=//div[contains(@class, 'tiptap ProseMirror')]
    Input Text    xpath=//div[contains(@class, 'tiptap ProseMirror')]    note modifiée hors-ligne
    Sleep    2s
    ${updated_text}=    Get Text    xpath=//div[contains(@class, 'tiptap ProseMirror')]
    Should Be Equal As Strings    ${updated_text}    note modifiée hors-ligne
    Click Element    xpath=//button[contains(@class, 'ant-drawer-close')]
    Sleep    1s
    Click home button
    Close Browser
