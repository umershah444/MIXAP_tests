*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari

*** Keywords ***
Create Empty Augmented Activity For Audio Test
    [Documentation]    Create and snap the background of the "Audio Tool Test" activity, stopping right after validation so the audio tool can be exercised without navigating away.
    Open Web Application
    Create Activity
    Select Activity Type    Augmented activity
    Next button
    Sleep    2s
    Edit Activity Title    Audio Tool Test
    Next button
    Sleep    2s
    Provide Marker Image    Augmented activity    settle=5s
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    2s

Create Empty Augmented Activity For Audio Test - Slow 3G
    [Documentation]    Create and snap the background of the "Audio Tool Test Slow3G" activity under throttled network conditions, stopping right after validation so the audio tool can be exercised without navigating away.
    Open Web Application
    Set Network Speed
    Create Activity
    Select Activity Type    Augmented activity
    Next button
    Sleep    2s
    Edit Activity Title    Audio Tool Test Slow3G
    Next button
    Sleep    2s
    Provide Marker Image    Augmented activity    settle=5s
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    2s

*** Test Cases ***
Open application and create an empty activity - for microphone test
    [Tags]    safari-unverified
    Create Empty Augmented Activity For Audio Test

Select the audio tool and use Microphone
    [Tags]    chrome-only    safari-skip:microphone
    Click Element    xpath=//button[contains(@title, 'Audio')]
    Sleep    2s
    Click Element    xpath=//div[contains(@class, 'auras__popbar')]
    Wait Until Element Is Visible    xpath=(//form[@id='basic']//button[contains(@class,'ant-btn-icon-only')])[2]
    Click Element    xpath=(//form[@id='basic']//button[contains(@class,'ant-btn-icon-only')])[2]
    Wait Until Element Is Visible    xpath=//button[.//*[@data-testid='CircleIcon']]    5s
    Click Element    xpath=//button[.//*[@data-testid='CircleIcon']]
    Sleep    5s
    Click Element    xpath=//button[.//*[@data-testid='PauseIcon']]
    Click Element    xpath=//button[.//*[@data-testid='CheckIcon']]
    Sleep    2s
    Play Audio And Verify Playback
    Close Browser

Open application and create an empty activity - for upload test
    [Tags]    safari-unverified
    Create Empty Augmented Activity For Audio Test

Select the audio tool and upload a file
    [Tags]    safari-unverified
    Click Element    xpath=//button[contains(@title, 'Audio')]
    Sleep    2s
    Click Element    xpath=//div[contains(@class, 'auras__popbar')]
    Choose File Robust    id=basic_file    ${EXECDIR}/assets/moo1.wav
    Sleep    2s
    Click Element    xpath=//div[contains(@class, 'auras__popbar')]
    Sleep    5s
    Close Browser

Open application and create an empty activity - for microphone test - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Create Empty Augmented Activity For Audio Test - Slow 3G

Select the audio tool and use Microphone - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state    safari-skip:microphone
    Click Element    xpath=//button[contains(@title, 'Audio')]
    Sleep    2s
    Click Element    xpath=//div[contains(@class, 'auras__popbar')]
    Wait Until Element Is Visible    xpath=(//form[@id='basic']//button[contains(@class,'ant-btn-icon-only')])[2]
    Click Element    xpath=(//form[@id='basic']//button[contains(@class,'ant-btn-icon-only')])[2]
    Wait Until Element Is Visible    xpath=//button[.//*[@data-testid='CircleIcon']]    5s
    Click Element    xpath=//button[.//*[@data-testid='CircleIcon']]
    Sleep    5s
    Click Element    xpath=//button[.//*[@data-testid='PauseIcon']]
    Click Element    xpath=//button[.//*[@data-testid='CheckIcon']]
    Sleep    2s
    Play Audio And Verify Playback
    Close Browser

Open application and create an empty activity - for upload test - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-network
    Create Empty Augmented Activity For Audio Test - Slow 3G

Select the audio tool and upload a file - Slow 3G
    [Tags]    chrome-only    safari-skip:cdp-state
    Click Element    xpath=//button[contains(@title, 'Audio')]
    Sleep    2s
    Click Element    xpath=//div[contains(@class, 'auras__popbar')]
    Choose File Robust    id=basic_file    ${EXECDIR}/assets/moo1.wav
    Sleep    2s
    Click Element    xpath=//div[contains(@class, 'auras__popbar')]
    Sleep    5s
    Close Browser
