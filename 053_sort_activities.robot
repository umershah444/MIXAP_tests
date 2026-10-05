*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create two differently named activities
    [Documentation]    Creates two activities with distinct, alphabetically far-apart titles so the sort control's effect on their relative order can be verified unambiguously.
    [Tags]    safari-unverified
    Open Web Application without closing
    Maximize Browser Window
    Create empty augmented activity    alpha
    Wait For Activity    alpha
    Create empty augmented activity    omega
    Wait For Activity    omega

Default sort is A-Z
    [Documentation]    The sort control defaults to "Sort A-Z" - "alpha" should appear before "omega" in the grid's DOM order.
    [Tags]    safari-unverified
    Activity Should Appear Before    alpha    omega

Switching to Sort Z-A reverses the order
    [Documentation]    Selecting "Sort Z-A" should flip the relative order of the two activities.
    [Tags]    safari-unverified
    Set Sort Order    za
    Activity Should Appear Before    omega    alpha

Switching back to Sort A-Z restores the original order
    [Documentation]    Selecting "Sort A-Z" again should restore the original relative order.
    [Tags]    safari-unverified
    Set Sort Order    az
    Activity Should Appear Before    alpha    omega
    Close Browser

Create two differently named activities - Slow 3G
    [Documentation]    Creates two activities with distinct, alphabetically far-apart titles so the sort control's effect on their relative order can be verified unambiguously, under throttled network conditions.
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application without closing
    Set Network Speed
    Maximize Browser Window
    Create empty augmented activity    alpha Slow3G
    Wait For Activity    alpha Slow3G
    Create empty augmented activity    omega Slow3G
    Wait For Activity    omega Slow3G

Default sort is A-Z - Slow 3G
    [Documentation]    The sort control defaults to "Sort A-Z" - "alpha Slow3G" should appear before "omega Slow3G" in the grid's DOM order.
    [Tags]    chrome-only    safari-skip:cdp-state
    Activity Should Appear Before    alpha Slow3G    omega Slow3G

Switching to Sort Z-A reverses the order - Slow 3G
    [Documentation]    Selecting "Sort Z-A" should flip the relative order of the two activities.
    [Tags]    chrome-only    safari-skip:cdp-state
    Set Sort Order    za
    Activity Should Appear Before    omega Slow3G    alpha Slow3G

Switching back to Sort A-Z restores the original order - Slow 3G
    [Documentation]    Selecting "Sort A-Z" again should restore the original relative order.
    [Tags]    chrome-only    safari-skip:cdp-state
    Set Sort Order    az
    Activity Should Appear Before    alpha Slow3G    omega Slow3G
    Close Browser
