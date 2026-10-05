*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:offline-suite

*** Test Cases ***
Create empty association activity offline
    Open Web Application
    Maximize Browser Window
    Go Offline
    Create Activity

Select Type
    Select Activity Type    Pair Association

Edit activity details
    Edit Activity Title    activité numéro 1
    Edit Activity Instructions    instruction relative à l'activité numéro 1
    Next button

Snap the landscape
    Sleep    2s
    Provide Marker Image    Pair Association
    Sleep    2s

upload the 2nd image
    [Documentation]    upload the 2nd image using button and uploading methods, test could fail if you start them inside the /tests/ folder instead of the main folder due to the path management.
    Wait Until Element Is Visible   xpath=//*[@id="three-canvas"]/div[2]/div/div/div/div[2]/div[2]/div[2]/span/span[1]    15s
    Click Element    xpath=//*[@id="three-canvas"]/div[2]/div/div/div/div[2]/div[2]/div[2]/span/span[1]
    Sleep    5s
    Wait Until Element Is Visible    xpath=//button[.//span[text()='Snap']]    20s
    Click Element    xpath=//button[.//span[text()='Snap']]
    Sleep    2s
    Wait Until Element Is Visible    xpath=//button[.//span[text()='Save']]     10s
    Click Element    xpath=//button[.//span[text()='Save']]
    Sleep    2s

validate the media
    Next button
    Sleep    2s
    Validation button     #⚠️sometimes infinite loading may occures without explaination and it may requires to restart the tests
    Sleep    2s
    Next button

display activity
    Sleep    5s
    Wait For Detection Or Log Miss
    Click home button
    Close Browser
