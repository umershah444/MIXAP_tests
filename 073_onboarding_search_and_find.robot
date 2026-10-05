*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:onboarding-camera

*** Test Cases ***
Selecting Search and Find for the first time starts its onboarding tour and walks through it
    [Documentation]    Full step-by-step walkthrough of the "searchAndFind" tour (searchAndFindTour.ts, 13 steps) - auto-triggers the first time a fresh account picks the "Search and Find" (Validation type) card (see ActivityMenu.tsx's handleCardClick). Unlike Pair Association, this activity type genuinely goes through marker capture and compilation, so "Snap the background" and "Validate the image" (existing keywords) perform the real clicks steps 5-7 target ("marker-take-photo"/"snapshot-capture"/"snapshot-confirm"), and "Validation button" (fixed earlier this session to target the marker-features modal) performs step 9's real click. Steps 10-12 (the ValidationsPanel timer/message config, then a "try it out" freedom step) have no single required real action worth reproducing here, so they're advanced via the popover's own Next button. Step 13 is the final action step (hides Next - see teacherTour.ts's HIDE_NEXT_BUTTONS pattern reused across every tour file) whose real target is the editor's close button, so "Click home button" both leaves the editor and completes the tour in one click.
    ...
    ...    Note: 075/076 (autoTriggeredPath/guidedPath) document a confirmed app bug where completing those single-step tours never persists their "seen" flag. Verified live that this tour does NOT share that bug - driven through its full 13 real steps to natural completion, "mixap.onboarding.searchAndFindCompleted" is correctly persisted, so the bug appears specific to those two single-step tours rather than universal to every tour started via ActivityMenu.tsx's handleCardClick.
    Open Web Application
    Reset Onboarding Tour Flag    searchAndFind
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username}    test_${username}@example.com    password123
    Onboarding Tour Should Not Be Marked Completed    searchAndFind
    Create Activity
    Select Activity Type    Search and Find
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Edit Activity Title    recherche et trouve
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Edit Activity Instructions    instructions recherche et trouve
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Next button
    Wait For Onboarding Popover
    Snap the background
    Wait For Onboarding Popover
    Validate the image
    Wait For Onboarding Popover
    Next button
    Wait For Onboarding Popover
    Validation button
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Click home button
    Onboarding Tour Should Not Be Active
    Onboarding Tour Should Be Marked Completed    searchAndFind
    Delete Account    password123
    Close Browser
