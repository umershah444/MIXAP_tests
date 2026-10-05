*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
create 8 activities and 1 path
    [Tags]    safari-unverified
    Open Web Application without closing
    FOR    ${i}    IN RANGE    1    9
        Create empty augmented activity    activité numéro ${i}
    END
    Create empty path

put 8 activities in path
    [Tags]    safari-unverified
    FOR    ${i}    IN RANGE    1    9
        Add Activity to Path    activité numéro ${i}
    END

create 8 activities and 1 path - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application without closing
    Set Network Speed
    FOR    ${i}    IN RANGE    1    9
        Create empty augmented activity    activité numéro ${i}
    END
    Create empty path

put 8 activities in path - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    FOR    ${i}    IN RANGE    1    9
        Add Activity to Path    activité numéro ${i}
    END
