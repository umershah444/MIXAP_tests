*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource       ./ressources.robot

Suite Teardown    Run Keyword And Ignore Error    Close All Browsers
Test Setup    Skip Chrome-Only Test On Safari
Test Tags    chrome-only    safari-skip:offline-suite

*** Test Cases ***
Create empty Augmented activity offline
    Open Web Application
    Maximize Browser Window
    Go Offline
    Create Activity

Select Type
    Select Activity Type    Augmented activity

Edit activity details
    Edit Activity Title    activité numéro 1

Snap the background
    Next button
    Provide Marker Image    Augmented activity
    Sleep    2s
    Next button
    Sleep    2s
    Validation button

Add text to the augmented activity
    Wait Until Element Is Visible    xpath=//button[@title='Text']    15s
    Click Element    xpath=//button[@title='Text']
    Wait Until Element Is Visible    xpath=//textarea[@placeholder='Edit your text...']    15s
    Click Element    xpath=//textarea[@placeholder='Edit your text...']
    Input Text    xpath=//textarea[@placeholder='Edit your text...']    mon texte par défaut
    Sleep    2s

Change text
    Wait Until Element Is Visible    xpath=//textarea[@placeholder='Edit your text...']    15s
    Click Element    xpath=//textarea[@placeholder='Edit your text...']
    Input Text    xpath=//textarea[@placeholder='Edit your text...']    mon texte modifié

Change text properties to bold
    Sleep    2s
    Mouse Over    xpath=//textarea[@placeholder='Edit your text...']
    Wait Until Element Is Visible    xpath=//button[@value='bold']    15s
    Click Element    xpath=//button[@value='bold']
    Click Element    xpath=//textarea[@placeholder='Edit your text...']

    ${element}=    Get WebElement    xpath=//textarea[@placeholder='Edit your text...']
    ${font_weight}=    Execute Javascript    return window.getComputedStyle(arguments[0]).fontWeight;    ARGUMENTS    ${element}
    Log To Console    font-weight=${font_weight}
    Log    ${font_weight}
    Should Be True    ${font_weight} == 700

Change text properties to italic
    Mouse Over    xpath=//textarea[@placeholder='Edit your text...']
    Wait Until Element Is Visible    xpath=//button[@value='italic']    15s
    Click Element    xpath=//button[@value='italic']
    Click Element    xpath=//textarea[@placeholder='Edit your text...']

    ${element}=    Get WebElement    xpath=//textarea[@placeholder='Edit your text...']
    ${font_weight}=    Execute Javascript    return window.getComputedStyle(arguments[0]).fontStyle;    ARGUMENTS    ${element}
    Log To Console    font-style=${font_weight}
    Log    ${font_weight}
    Should Be True    '${font_weight}'    'italic'

Change text properties to small-caps
    Mouse Over    xpath=//textarea[@placeholder='Edit your text...']
    Wait Until Element Is Visible    xpath=//button[@value='small-caps']    15s
    Click Element    xpath=//button[@value='small-caps']
    Click Element    xpath=//textarea[@placeholder='Edit your text...']

    ${element}=    Get WebElement    xpath=//textarea[@placeholder='Edit your text...']
    ${font_weight}=    Execute Javascript    return window.getComputedStyle(arguments[0]).fontVariant;    ARGUMENTS    ${element}
    Log To Console    font-variant=${font_weight}
    Log    ${font_weight}
    Should Be True    '${font_weight}'    'small-caps'

Change text to normal
    Wait Until Element Is Visible    xpath=//button[@value='normal']    15s

    ${elements}=    Get WebElements    xpath=//button[@value='normal']

    FOR    ${elem}    IN    ${elements}
        Mouse Over    ${elem}
        Click Element    ${elem}
    END

    Sleep    2s

    ${element}=    Get WebElement    xpath=//textarea[@placeholder='Edit your text...']
    ${font_weight}=    Execute Javascript    return window.getComputedStyle(arguments[0]).fontWeight;    ARGUMENTS    ${element}
    Log To Console    font-weight=${font_weight}
    Log    ${font_weight}
    Should Be True    ${font_weight}    400

    ${element}=    Get WebElement    xpath=//textarea[@placeholder='Edit your text...']
    ${font_weight}=    Execute Javascript    return window.getComputedStyle(arguments[0]).fontStyle;    ARGUMENTS    ${element}
    Log To Console    font-style=${font_weight}
    Log    ${font_weight}
    Should Be True    '${font_weight}'    'normal'

    ${element}=    Get WebElement    xpath=//textarea[@placeholder='Edit your text...']
    ${font_weight}=    Execute Javascript    return window.getComputedStyle(arguments[0]).fontVariant;    ARGUMENTS    ${element}
    Log To Console    font-variant=${font_weight}
    Log    ${font_weight}
    Should Be True    '${font_weight}'    'normal'
