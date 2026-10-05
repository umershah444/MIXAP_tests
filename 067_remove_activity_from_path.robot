*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create two activities and a path with both added
    [Documentation]    Creates two activities and a path containing both, so removal can be verified against a known baseline. The removal mechanism itself is non-obvious (confirmed live): clicking a mini-card's title inside the path content drawer selects it and reveals a floating "Remove" action, distinct from the mini-card's own "..." menu (whose "Delete" item instead fully deletes the activity everywhere - see "Delete Activity From Path Drawer By Id").
    [Tags]    safari-unverified
    Open Web Application without closing
    Maximize Browser Window
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    ${username}    test_${username}@example.com    password123
    Create empty augmented activity    activity one
    ${id1}=    Get Card Data Id    activity one
    Set Suite Variable    ${id1}
    Create empty augmented activity    activity two
    ${id2}=    Get Card Data Id    activity two
    Set Suite Variable    ${id2}
    Create empty path    title=remove test path
    ${path_id}=    Get Card Data Id    remove test path
    Set Suite Variable    ${path_id}
    Add Activity to Path By Id    ${id1}    ${path_id}
    Add Activity to Path By Id    ${id2}    ${path_id}

Both activities are present in the path before removal
    [Documentation]    Confirms the baseline state: both activities show up in the path's content drawer.
    [Tags]    safari-unverified
    Open Path Content Drawer    ${path_id}
    ${both_ids}=    Create List    ${id1}    ${id2}
    Path Should Contain Activities    ${both_ids}

Removing one activity from the path leaves only the other
    [Documentation]    Removes the first activity from the path (via the select + floating "Remove" action, not the destructive per-card menu) and confirms only the second remains in the path.
    [Tags]    safari-unverified
    Remove Activity From Path By Id    ${id1}
    ${removed_id}=    Create List    ${id1}
    ${missing}=    Get Missing Activity Ids    ${removed_id}
    Should Be Equal    ${missing}    ${removed_id}
    ${remaining_id}=    Create List    ${id2}
    Path Should Contain Activities    ${remaining_id}
    Close Path Content Drawer

The removed activity still exists independently on the home grid
    [Documentation]    Confirms the removal was non-destructive: unlike deleting an activity, removing it from a path leaves it fully intact as its own card on the home grid.
    [Tags]    safari-unverified
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'activity-card') and @data-id='${id1}']    10s
    Delete Account    password123
    Close Browser

Create two activities and a path with both added - Slow 3G
    [Documentation]    Same as above, under throttled network conditions.
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application without closing
    Set Network Speed
    Maximize Browser Window
    ${username}=    Generate Random String    10    [LETTERS][NUMBERS]
    Sign Up    ${username}    test_${username}@example.com    password123
    Create empty augmented activity    activity one
    ${id1}=    Get Card Data Id    activity one
    Set Suite Variable    ${id1}
    Create empty augmented activity    activity two
    ${id2}=    Get Card Data Id    activity two
    Set Suite Variable    ${id2}
    Create empty path    title=remove test path
    ${path_id}=    Get Card Data Id    remove test path
    Set Suite Variable    ${path_id}
    Add Activity to Path By Id    ${id1}    ${path_id}
    Add Activity to Path By Id    ${id2}    ${path_id}

Both activities are present in the path before removal - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Open Path Content Drawer    ${path_id}
    ${both_ids}=    Create List    ${id1}    ${id2}
    Path Should Contain Activities    ${both_ids}

Removing one activity from the path leaves only the other - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Remove Activity From Path By Id    ${id1}
    ${removed_id}=    Create List    ${id1}
    ${missing}=    Get Missing Activity Ids    ${removed_id}
    Should Be Equal    ${missing}    ${removed_id}
    ${remaining_id}=    Create List    ${id2}
    Path Should Contain Activities    ${remaining_id}
    Close Path Content Drawer

The removed activity still exists independently on the home grid - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'activity-card') and @data-id='${id1}']    10s
    Delete Account    password123
    Close Browser
