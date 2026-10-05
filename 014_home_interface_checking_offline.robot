*** Settings ***
Library    SeleniumLibrary
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:offline-suite

*** Test Cases ***
open Application
    Open Web Application
    Maximize Browser Window
    Go Offline

Change to French
    Open drawer
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'ant-space-item')]//span[text()='Français']    10s
    Click Element    xpath=//div[contains(@class, 'ant-space-item')]//span[text()='Français']
    Wait Until Element Contains    xpath=//body    Nouvelle activité    10s

Change to Danish
    Open drawer
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'ant-space-item')]//span[text()='Dansk']    10s
    Click Element    xpath=//div[contains(@class, 'ant-space-item')]//span[text()='Dansk']
    Wait Until Element Contains    xpath=//body    Ny aktivitet    10s

Change to Greek
    Open drawer
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'ant-space-item')]//span[text()='Ελληνικά']    10s
    Click Element    xpath=//div[contains(@class, 'ant-space-item')]//span[text()='Ελληνικά']
    Wait Until Element Contains    xpath=//body    Νέα δραστηριότητα    10s

Change to Turkish
    Open drawer
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'ant-space-item')]//span[text()='Türkçe']    10s
    Click Element    xpath=//div[contains(@class, 'ant-space-item')]//span[text()='Türkçe']
    Wait Until Element Contains    xpath=//body    Yeni etkinlik    10s

Change to English
    Open drawer
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'ant-space-item')]//span[text()='English']    10s
    Click Element    xpath=//div[contains(@class, 'ant-space-item')]//span[text()='English']
    Wait Until Element Contains    xpath=//body    New activity    10s

Check filtering activities buttons
    Create empty augmented activity    augmentation numéro 1
    Create empty augmented activity    augmentation numéro 2
    Create empty validation    validation numéro 1    instruction 1
    Create empty validation    validation numéro 2    instruction 2
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__filter-btn') and @title='Filter']    timeout=10
    Click Element    xpath=//button[contains(@class, 'home__filter-btn') and @title='Filter']
    Wait Until Element Is Visible    xpath=//label[.//span[text()='Augmented activity']]    timeout=10
    Click Element    xpath=//label[.//span[text()='Augmented activity']]
    Wait Until Element Contains    xpath=//body//*[text()='Augmented activity']    text=Augmented activity    timeout=10
    Element Should Not Contain    xpath=//div[contains(@class, 'home__grid')]    Search and Find
    Wait Until Element Is Visible    xpath=//label[.//span[text()='Augmented activity']]    timeout=10
    Click Element    xpath=//label[.//span[text()='Augmented activity']]
    Wait Until Element Is Visible    xpath=//label[.//span[text()='Search and Find']]    timeout=10
    Click Element    xpath=//label[.//span[text()='Search and Find']]
    Wait Until Element Contains    xpath=//body//*[text()='Search and Find']    text=Search and Find    timeout=10
    Element Should Not Contain    xpath=//div[contains(@class, 'home__grid')]    Augmented activity
    Close Browser

*** Keywords ***
Open drawer
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'ant-select') and contains(@class, 'ant-select-single') and contains(@class, 'ant-select-show-arrow')]
    Click Element    xpath=//div[contains(@class, 'ant-select') and contains(@class, 'ant-select-single') and contains(@class, 'ant-select-show-arrow')]
