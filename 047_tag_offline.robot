*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:offline-suite

*** Test Cases ***
Create activity with tag
    [Documentation]    Mirrors 029_tag.robot's non-offline flow: "Create empty augmented activity" ends back on the home grid, not the editor's own tag UI, so the editor must be reopened first before "Add Tag to Activity" can find its "editor__tags-chip" trigger - see 029's docstring for the full explanation. Unlike 029, this cannot use "Reopen Activity Editor" to get there: that keyword's mechanism is a hard "Reload Page", and reloading a genuinely offline browser (CDP "Network.emulateNetworkConditions" offline - confirmed live) does not just degrade gracefully like an already-loaded SPA would - it re-does the full HTTP navigation and lands on Chrome's own native "ERR_INTERNET_DISCONNECTED" interstitial instead of the app. "Open Activity Menu And Edit" reopens the just-created activity directly from the home grid using already-loaded local state instead - no reload, no network needed. "Click home button" afterwards returns to the state "Delete Tag from Activity" expects (its "home__labels-btn" trigger lives on the home grid).
    Open Web Application
    Go Offline
    Create empty augmented activity    activité numéro 1
    Open Activity Menu And Edit    activité numéro 1
    Sleep    2s
    Add Tag to Activity    tag numéro 1
    Click home button

Delete tag from activity
    Delete Tag from Activity    tag numéro 1
    Close Browser
