*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:offline-suite

*** Test Cases ***
create 8 activities and 1 path
    Open Web Application without closing
    Go Offline
    FOR    ${i}    IN RANGE    1    9
        Create empty augmented activity    activité numéro ${i}
    END
    Create empty path

put 8 activities in path
    FOR    ${i}    IN RANGE    1    9
        Add Activity to Path    activité numéro ${i}
    END
