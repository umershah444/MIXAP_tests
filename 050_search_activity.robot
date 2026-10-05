*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Variables ***
${title_a}    value
${title_b}    value

*** Test Cases ***
Create two differently named activities
    [Documentation]    Creates two activities with distinct, unique titles so the search filter's effect can be verified unambiguously.
    [Tags]    safari-unverified
    Open Web Application without closing
    Maximize Browser Window
    # Deliberately no shared word between the two titles (not even "search"/"activity"): the
    # search box appears to match on individual words, not just the full string, so any shared
    # word would make both cards match either search and defeat the point of this test.
    ${title_a}=    Set Variable    zeta
    ${title_b}=    Set Variable    omega
    Set Suite Variable    ${title_a}
    Set Suite Variable    ${title_b}
    Create empty augmented activity    ${title_a}
    Create empty augmented activity    ${title_b}
    Wait For Activity    ${title_a}
    Wait For Activity    ${title_b}

Search narrows the grid to the matching activity only
    [Documentation]    Searching for one activity's exact title should show that card and hide the other.
    [Tags]    safari-unverified
    Search For    zeta
    Wait For Activity    zeta
    Page Should Not Contain Element    xpath=//h3[contains(@class, 'activity-card') and text()='omega']

Searching for the other title swaps which activity is shown
    [Documentation]    Replacing the search text with the second activity's title should now show that one and hide the first.
    [Tags]    safari-unverified
    Search For    ${title_b}
    Wait For Activity    ${title_b}
    Page Should Not Contain Element    xpath=//h3[contains(@class, 'activity-card') and text()='zeta']

Clearing the search shows both activities again
    [Documentation]    Clearing the search box should bring back both activities.
    [Tags]    safari-unverified
    Search For    ${EMPTY}
    Wait For Activity    ${title_a}
    Wait For Activity    ${title_b}
    Close Browser

Create two differently named activities - Slow 3G
    [Documentation]    Creates two activities with distinct, unique titles so the search filter's effect can be verified unambiguously, under throttled network conditions.
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application without closing
    Set Network Speed
    Maximize Browser Window
    # Deliberately no shared word between the two titles (not even "search"/"activity"): the
    # search box appears to match on individual words, not just the full string, so any shared
    # word would make both cards match either search and defeat the point of this test.
    ${title_a}=    Set Variable    kappa
    ${title_b}=    Set Variable    sigma
    Set Suite Variable    ${title_a}
    Set Suite Variable    ${title_b}
    Create empty augmented activity    ${title_a}
    Create empty augmented activity    ${title_b}
    Wait For Activity    ${title_a}
    Wait For Activity    ${title_b}

Search narrows the grid to the matching activity only - Slow 3G
    [Documentation]    Searching for one activity's exact title should show that card and hide the other.
    [Tags]    chrome-only    safari-skip:cdp-state
    Search For    kappa
    Wait For Activity    kappa
    Page Should Not Contain Element    xpath=//h3[contains(@class, 'activity-card') and text()='sigma']

Searching for the other title swaps which activity is shown - Slow 3G
    [Documentation]    Replacing the search text with the second activity's title should now show that one and hide the first.
    [Tags]    chrome-only    safari-skip:cdp-state
    Search For    ${title_b}
    Wait For Activity    ${title_b}
    Page Should Not Contain Element    xpath=//h3[contains(@class, 'activity-card') and text()='kappa']

Clearing the search shows both activities again - Slow 3G
    [Documentation]    Clearing the search box should bring back both activities.
    [Tags]    chrome-only    safari-skip:cdp-state
    Search For    ${EMPTY}
    Wait For Activity    ${title_a}
    Wait For Activity    ${title_b}
    Close Browser
