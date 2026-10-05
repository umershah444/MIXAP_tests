*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Open application and change language
    [Tags]    safari-unverified
    Open Web Application
    Change Language    Français
    Sleep    5s

Test everything is in French
    [Tags]    safari-unverified
    Check that the page is in French

Test everything is in English
    [Tags]    safari-unverified
    Change Language    English
    Sleep    5s
    Check that the page is in English

Test everything is in Danish
    [Tags]    safari-unverified
    Change Language    Dansk
    Sleep    5s
    Check that the page is in Danish

Test everything is in Greek
    [Tags]    safari-unverified
    Change Language    Ελληνικά
    Sleep    5s
    Check that the page is in Greek

Test everything is in Turkish
    [Tags]    safari-unverified
    Change Language    Türkçe
    Sleep    5s
    Check that the page is in Turkish
    Close Browser

Open application and change language - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Set Network Speed
    Change Language    Français
    Sleep    5s

Test everything is in French - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Check that the page is in French

Test everything is in English - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Change Language    English
    Sleep    5s
    Check that the page is in English

Test everything is in Danish - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Change Language    Dansk
    Sleep    5s
    Check that the page is in Danish

Test everything is in Greek - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Change Language    Ελληνικά
    Sleep    5s
    Check that the page is in Greek

Test everything is in Turkish - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Change Language    Türkçe
    Sleep    5s
    Check that the page is in Turkish
    Close Browser
