*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:offline-suite

*** Test Cases ***
Create two differently named activities
    [Documentation]    Creates two activities with distinct, alphabetically far-apart titles so the sort control's effect on their relative order can be verified unambiguously.
    Open Web Application without closing
    Go Offline
    Maximize Browser Window
    Create empty augmented activity    alpha
    Wait For Activity    alpha
    Create empty augmented activity    omega
    Wait For Activity    omega

Default sort is A-Z
    [Documentation]    The sort control defaults to "Sort A-Z" - "alpha" should appear before "omega" in the grid's DOM order.
    Activity Should Appear Before    alpha    omega

Switching to Sort Z-A reverses the order
    [Documentation]    Selecting "Sort Z-A" should flip the relative order of the two activities.
    Set Sort Order    za
    Activity Should Appear Before    omega    alpha

Switching back to Sort A-Z restores the original order
    [Documentation]    Selecting "Sort A-Z" again should restore the original relative order.
    Set Sort Order    az
    Activity Should Appear Before    alpha    omega
    Close Browser