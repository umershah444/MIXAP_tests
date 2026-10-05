*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create activity with tag
    [Documentation]    "Create empty augmented activity" ends back on the home grid (its last step is "Click home button"), but "Add Tag to Activity" targets the editor's own tag UI ("editor__tags-chip") - so the activity's editor must be reopened first, and "Click home button" called again afterwards to leave the state "Delete Tag from Activity" expects (its "home__labels-btn" trigger lives on the home grid).
    [Tags]    safari-unverified
    Open Web Application
    Create empty augmented activity    activité numéro 1
    Reopen Activity Editor    activité numéro 1
    Add Tag to Activity    tag numéro 1
    Click home button

Delete tag from activity
    [Tags]    safari-unverified
    Delete Tag from Activity    tag numéro 1
    Close Browser

Create activity with tag - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Create empty augmented activity    activité numéro 1 Slow3G
    Reopen Activity Editor    activité numéro 1 Slow3G
    Add Tag to Activity    tag numéro 1
    Click home button

Delete tag from activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Delete Tag from Activity    tag numéro 1
    Close Browser
