*** Settings ***
Library    SeleniumLibrary
Resource       ./ressources.robot
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:offline-suite

*** Test Cases ***
Open Web Application Offline
    Open Web Application Without Fake Media
    Go Offline
    Title Should Be    MIXAP
    Sleep    5s   # Attend 5 secondes pour vérifier si la page s'ouvre correctement
    Close All Browsers
