*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Tags    safari-unverified

*** Test Cases ***
The student tour walks through the import flow
    [Documentation]    Full step-by-step walkthrough of the "student" tour (studentTour.ts, 7 steps) - reached via the "main" tour's "I'm a student" role picker (mainTour.ts). Students import an activity a teacher already shared rather than build one, so this tour is much shorter than teacherTour.ts. Step 2 is the only action step (its real target - "[data-tour='home-import-activity']" - opens the Import modal); the two freedom steps (4, 6 - "pick one of several real import paths: scan QR or type a code" / general exploration) have no single required action worth reproducing here (a real cross-account share-code import, as done in 031_import.robot, would need a second throwaway account purely to generate a code), so both are advanced via the popover's own Next button instead, same as the plain info steps.
    Open Web Application
    Reset Onboarding Tour Flag    main
    Reset Onboarding Tour Flag    student
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username}    test_${username}@example.com    password123
    Onboarding Tour Should Not Be Marked Completed    student
    Wait For Onboarding Popover
    Choose Onboarding Role    student
    Onboarding Tour Should Be Marked Completed    main
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Wait Until Element Is Visible    xpath=//*[@data-tour='home-import-activity']    5s
    Click Element    xpath=//*[@data-tour='home-import-activity']
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Close Onboarding Tour If Still Active
    Onboarding Tour Should Not Be Active
    Onboarding Tour Should Be Marked Completed    student
    Reload Page
    Wait Until Element Is Visible    xpath=//button[text()='New activity']    15s
    Delete Account    password123
    Close Browser
