*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:camera-todo

*** Test Cases ***
Selecting Information layers for the first time starts its onboarding tour and walks through it
    [Documentation]    Full step-by-step walkthrough of the "informationLayer" tour (informationLayerTour.ts, 17 steps) - auto-triggers the first time a fresh account picks the "Information layers" (Superposition type) card (see ActivityMenu.tsx's handleCardClick). Steps 1-9 mirror searchAndFindTour's naming + marker capture/compile sequence (same "Snap the background"/"Validate the image"/"Next button"/"Validation button" real actions). Steps 11-12 drive the real LayersPanel UI directly by its own BEM classes (per informationLayerTour.ts's own comment: already unique/stable, no dedicated data-tour attributes) - step 11 adds a new layer, step 12 confirms its inline name input. Steps 10/13/16 are open-ended "freedom" exploration steps (add auras, arrange layers) with no single required action, so advanced via the popover's own Next button. Step 17 is the final action step whose real target is the editor's close button.
    ...
    ...    Note: 075/076 (autoTriggeredPath/guidedPath) document a confirmed app bug where completing those single-step tours never persists their "seen" flag. Verified live that this tour does NOT share that bug - driven through its full 17 real steps to natural completion, "mixap.onboarding.informationLayerCompleted" is correctly persisted, so the bug appears specific to those two single-step tours rather than universal to every tour started via ActivityMenu.tsx's handleCardClick. A final action step's real click occasionally races ahead of driverInstance.ts's listener attachment though (see "Close Onboarding Tour If Still Active"), so that fallback is used defensively here.
    Open Web Application
    Reset Onboarding Tour Flag    informationLayer
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    test_${username}    test_${username}@example.com    password123
    Onboarding Tour Should Not Be Marked Completed    informationLayer
    Create Activity
    Select Activity Type    Information layers
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Edit Activity Title    couches d'information
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Edit Activity Instructions    instructions couches d'information
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
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'layers-panel__add-button')]    5s
    Click Element    xpath=//button[contains(@class, 'layers-panel__add-button')]
    Wait For Onboarding Popover
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'layers-panel__add-row')]//button[contains(@class, 'layers-panel__edit-button--validate')]    5s
    Click Element    xpath=//div[contains(@class, 'layers-panel__add-row')]//button[contains(@class, 'layers-panel__edit-button--validate')]
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Click Onboarding Next Button
    Wait For Onboarding Popover
    Click home button
    Close Onboarding Tour If Still Active
    Onboarding Tour Should Not Be Active
    Onboarding Tour Should Be Marked Completed    informationLayer
    Delete Account    password123
    Close Browser
