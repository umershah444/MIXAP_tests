*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:offline-suite

*** Test Cases ***
Open application and change language
    Open Web Application
    Go Offline
    Change Language    Français
    Sleep    5s

Test everything is in French
    Check that the page is in French

Test everything is in English
    Change Language    English
    Sleep    5s
    Check that the page is in English

Test everything is in Danish
    Change Language    Dansk
    Sleep    5s
    Check that the page is in Danish

Test everything is in Greek
    Change Language    Ελληνικά
    Sleep    5s
    Check that the page is in Greek

Test everything is in Turkish
    Change Language    Türkçe
    Sleep    5s
    Check that the page is in Turkish
    Close Browser
