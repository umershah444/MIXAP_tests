*** Settings ***
Library    SeleniumLibrary
Resource       ./ressources.robot
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Open Web Application
    [Tags]    safari-unverified
    Open Web Application Without Fake Media
    Title Should Be    MIXAP
    Sleep    5s   # Attend 5 secondes pour vérifier si la page s'ouvre correctement
    Close All Browsers

Open Web Application - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application Without Fake Media
    Set Network Speed
    Title Should Be    MIXAP
    Sleep    5s   # Attend 5 secondes pour vérifier si la page s'ouvre correctement
    Close All Browsers
