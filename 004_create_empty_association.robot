*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Test Cases ***
Create empty association activity
    [Tags]    safari-unverified
    Open Web Application
    Maximize Browser Window
    Create Activity

Select Type
    [Tags]    safari-unverified
    Select Activity Type    Pair Association

Edit activity details
    [Tags]    safari-unverified
    Edit Activity Title    activité numéro 1
    Edit Activity Instructions    instruction relative à l'activité numéro 1
    Next button

Snap the landscape
    [Tags]    chrome-only    safari-skip:camera-todo
    Sleep    2s
    Provide Marker Image    Pair Association
    Sleep    2s

upload the 2nd image
    [Documentation]    upload the 2nd image using button and uploading methods, test could fail if you start them inside the /tests/ folder instead of the main folder due to the path management.
    [Tags]    chrome-only    safari-skip:camera-todo
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
    [Tags]    chrome-only    safari-skip:session-of-skipped
    Next button
    Sleep    2s
    Validation button     #⚠️sometimes infinite loading may occures without explaination and it may requires to restart the tests
    Sleep    2s
    Next button

display activity
    [Tags]    chrome-only    safari-skip:session-of-skipped
    Sleep    5s
    Wait For Detection Or Log Miss
    Click home button
    Close Browser

Create empty association activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Open Web Application
    Maximize Browser Window
    Set Network Speed
    Create Activity

Select Type - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Select Activity Type    Pair Association

Edit activity details - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Edit Activity Title    activité numéro 1 Slow3G
    Edit Activity Instructions    instruction relative à l'activité numéro 1
    Next button

Snap the landscape - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state    safari-skip:camera-todo
    Sleep    2s
    Provide Marker Image    Pair Association
    Sleep    2s

upload the 2nd image - Slow 3G
    [Documentation]    upload the 2nd image using button and uploading methods, test could fail if you start them inside the /tests/ folder instead of the main folder due to the path management.
    [Tags]    chrome-only    safari-skip:cdp-state    safari-skip:camera-todo
    Wait Until Element Is Visible   xpath=//*[@id="three-canvas"]/div[2]/div/div/div/div[2]/div[2]/div[2]/span/span[1]    15s
    Click Element    xpath=//*[@id="three-canvas"]/div[2]/div/div/div/div[2]/div[2]/div[2]/span/span[1]
    Sleep    5s
    Wait Until Element Is Visible    xpath=//button[.//span[text()='Snap']]    20s
    Click Element    xpath=//button[.//span[text()='Snap']]
    Sleep    2s
    Wait Until Element Is Visible    xpath=//button[.//span[text()='Save']]     10s
    Click Element    xpath=//button[.//span[text()='Save']]
    Sleep    2s

validate the media - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Next button
    Sleep    2s
    Validation button     #⚠️sometimes infinite loading may occures without explaination and it may requires to restart the tests
    Sleep    2s
    Next button

display activity - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Sleep    5s
    Wait For Detection Or Log Miss
    Click home button
    Close Browser
