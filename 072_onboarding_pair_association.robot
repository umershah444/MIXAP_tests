*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Tags    safari-unverified

*** Test Cases ***
Selecting Pair Association for the first time starts its onboarding tour and walks through it
    [Documentation]    Full step-by-step walkthrough of the "pairAssociation" tour (pairAssociationTour.ts, 10 steps) - auto-triggers the first time a fresh account picks the "Pair Association" card (see ActivityMenu.tsx's handleCardClick). Steps 1-3 are info-only (no real action, just the popover's own "Next"); step 4 is an action step whose real target IS the editor's "Next" button, so clicking it both names the activity and advances the tour in one click; steps 5-6 are "freedom" steps that auto-advance once each marker slot's uploaded image appears (advanceOnElementAppear, see driverInstance.ts), no manual click needed; step 7's target only exists for marker-compiled activity types (useMarkerCompiler in Editor.tsx) - Pair Association's two images are plain uploads, not marker compilation (confirmed live while fixing 037_pairs.robot), so driver.js's "skipMissingElement: true" silently skips it - the remaining tail is walked with "Finish Onboarding Tour By Clicking Next" rather than a hardcoded step count for that reason.
    ...
    ...    KNOWN APP BUG (confirmed live, not a test issue - see 075/076's docs for the full write-up): completing this tour never persists "mixap.onboarding.pairAssociationCompleted" to localStorage, for any of the 5 tours started via ActivityMenu.tsx's handleCardClick. Kept as a real (expected-to-fail) assertion rather than weakened.
    Open Web Application
    Reset Onboarding Tour Flag    pairAssociation
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username}    test_${username}@example.com    password123
    Onboarding Tour Should Not Be Marked Completed    pairAssociation
    Create Activity
    Select Activity Type    Pair Association
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Edit Activity Title    activité par paires
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Edit Activity Instructions    instructions par paires
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Next button
    Wait For Onboarding Popover
    ${progress}=    Get Onboarding Popover Progress
    Wait Until Element Is Visible    xpath=(//div[contains(@class, 'mk-upload__marker-slot')]//span[contains(@class, 'ant-upload-btn')])[1]    15s
    Click Element    xpath=(//div[contains(@class, 'mk-upload__marker-slot')]//span[contains(@class, 'ant-upload-btn')])[1]
    Wait Until Page Contains Element    xpath=//input[@type='file']    5s
    Choose File Robust    xpath=//input[@type='file']    ${EXECDIR}/assets/fakecamfeed_cortez.png
    Onboarding Popover Should Have Advanced From    ${progress}
    ${progress2}=    Get Onboarding Popover Progress
    Wait Until Element Is Visible    xpath=(//div[contains(@class, 'mk-upload__marker-slot')]//span[contains(@class, 'ant-upload-btn')])[1]    15s
    Click Element    xpath=(//div[contains(@class, 'mk-upload__marker-slot')]//span[contains(@class, 'ant-upload-btn')])[1]
    Wait Until Page Contains Element    xpath=//input[@type='file']    5s
    Choose File Robust    xpath=//input[@type='file']    ${EXECDIR}/assets/cat.webp
    Onboarding Popover Should Have Advanced From Or Click Next    ${progress2}
    Next button
    Sleep    2s
    Finish Onboarding Tour By Clicking Next
    Onboarding Tour Should Not Be Active
    Onboarding Tour Should Be Marked Completed    pairAssociation
    Click home button
    Wait Until Element Is Visible    xpath=//button[text()='New activity']    15s
    Delete Account    password123
    Close Browser
