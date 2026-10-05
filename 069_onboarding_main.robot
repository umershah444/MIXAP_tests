*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Tags    safari-unverified

*** Test Cases ***
The main tour auto-triggers on first Home visit and offers no default buttons
    [Documentation]    Verifies the "main" tour (mainTour.ts) auto-triggers the first time a fresh account visits Home (see Home.tsx's "mainTourSeen" effect). It renders with "showButtons: []" - no driver.js Previous/Next footer buttons - only the two custom "I'm a teacher" / "I'm a student" role-picker buttons injected via onPopoverRender. The corner "X" close button is a separate driver.js fixture unaffected by "showButtons" (verified live: it's still present), so this only asserts the footer buttons are absent.
    Open Web Application
    Reset Onboarding Tour Flag    main
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username}    test_${username}@example.com    password123
    Onboarding Tour Should Not Be Marked Completed    main
    Wait For Onboarding Popover
    Page Should Not Contain Element    xpath=//button[contains(@class, 'driver-popover-next-btn')]
    Page Should Not Contain Element    xpath=//button[contains(@class, 'driver-popover-prev-btn')]
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'onboarding-role-picker__btn') and @data-role='teacher']    5s
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'onboarding-role-picker__btn') and @data-role='student']    5s

Choosing "I'm a teacher" completes the main tour and launches the teacher tour
    [Documentation]    Continues from the previous test case's still-open main tour. Picking a role destroys the main tour's driver instance before starting the next one (see OnboardingProvider.tsx's "goTo()"), which fires "onDestroyed" and marks "main" completed even though no Next/Done button was ever clicked.
    Choose Onboarding Role    teacher
    Onboarding Tour Should Be Marked Completed    main
    Wait For Onboarding Popover
    Click Onboarding Close Button
    Onboarding Tour Should Not Be Active
    Onboarding Tour Should Be Marked Completed    teacher
    Delete Account    password123
    Close Browser

Choosing "I'm a student" completes the main tour and launches the student tour
    [Documentation]    Same branch as the previous test case, but picking "student" instead - uses a fresh account since the previous one already consumed its "main" tour.
    Open Web Application
    Reset Onboarding Tour Flag    main
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username}    test_${username}@example.com    password123
    Wait For Onboarding Popover
    Choose Onboarding Role    student
    Onboarding Tour Should Be Marked Completed    main
    Wait For Onboarding Popover
    Click Onboarding Close Button
    Onboarding Tour Should Not Be Active
    Onboarding Tour Should Be Marked Completed    student
    Delete Account    password123
    Close Browser

Replaying the tour from the header menu re-shows it after it has already been seen
    [Documentation]    Verifies the header's "Replay guided tour" menu item (PageHeader.tsx) re-launches the "main" tour on demand, ignoring the "seen" flag - the one way to see it again once a role has already been picked.
    Open Web Application
    Reset Onboarding Tour Flag    main
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username}    test_${username}@example.com    password123
    Wait For Onboarding Popover
    Choose Onboarding Role    teacher
    Onboarding Tour Should Be Marked Completed    main
    Wait For Onboarding Popover
    Click Onboarding Close Button
    Onboarding Tour Should Not Be Active
    Replay Onboarding Tour
    Wait For Onboarding Popover
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'onboarding-role-picker__btn') and @data-role='teacher']    5s
    Choose Onboarding Role    student
    Wait For Onboarding Popover
    Click Onboarding Close Button
    Delete Account    password123
    Close Browser
