*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Tags    safari-unverified

*** Test Cases ***
Selecting Auto-Triggered path for the first time starts its onboarding tour
    [Documentation]    The "autoTriggeredPath" tour is a single info step with no dedicated wizard steps of its own (autoTriggeredPathTour.ts) - it auto-triggers the first time a fresh account picks the "Auto-Triggered path" card from the New Path menu (see ActivityMenu.tsx's handleCardClick). Verifies the tour appears, can be advanced via its own "Next"/"Done" button, and marks itself completed.
    ...
    ...    KNOWN APP BUG (confirmed live, not a test issue): the "Onboarding Tour Should Be Marked Completed" assertion below currently fails - closing this tour (via either its Next/Done button or the X) never writes "mixap.onboarding.autoTriggeredPathCompleted" to localStorage at all (verified by monkey-patching localStorage.setItem: the key is never touched). The "main"/"teacher"/"student" tours complete correctly; this affects specifically the 5 tours started via ActivityMenu.tsx's handleCardClick, which calls navigate() immediately before startTour() - unlike main/teacher/student, which never navigate first. Kept as a real (expected-to-fail) assertion rather than weakened, so this test accurately reports the bug instead of hiding it.
    Open Web Application
    Reset Onboarding Tour Flag    autoTriggeredPath
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username}    test_${username}@example.com    password123
    Onboarding Tour Should Not Be Marked Completed    autoTriggeredPath
    Create Path
    Select Path Type    Auto-Triggered Path
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Onboarding Tour Should Not Be Active
    Onboarding Tour Should Be Marked Completed    autoTriggeredPath
    Wait Until Element Is Visible    xpath=//input[contains(@class, 'activity-view__input--title')]    5s
    Edit Path Title    parcours auto-déclenché
    Edit Path Instructions    instructions parcours auto-déclenché

Creating a second Auto-Triggered path does not re-trigger the tour once the "seen" flag is set
    [Documentation]    Tests the READ/gating side of tour suppression in isolation from the write-side bug documented in the previous test case - the app's own path to persist "seen" is confirmed broken, but that says nothing about whether ActivityMenu.tsx correctly honors the flag once it IS set, so this sets it directly via localStorage rather than depending on the previous test case's (currently failing) completion step. Reloads first: verified live that "ActivityMenu.tsx" reads this flag through its own separate "usePersistentState" hook instance, distinct from the one "OnboardingProvider.tsx" writes through - the two never reactively sync with each other, so the guard only takes effect once the page (and therefore ActivityMenu) actually remounts and re-reads localStorage.
    Click home button and discard draft
    Execute Javascript    localStorage.setItem('mixap.onboarding.autoTriggeredPathCompleted', 'true');
    Reload Page
    Wait Until Element Is Visible    xpath=//button[text()='New activity']    15s
    Create Path
    Select Path Type    Auto-Triggered Path
    Sleep    2s
    Onboarding Tour Should Not Be Active
    Click home button and discard draft
    Delete Account    password123
    Close Browser
