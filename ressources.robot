*** Settings ***
Library    SeleniumLibrary
Library    Collections

*** Variables ***
${URL}    https://mixap-lium-preprod.univ-lemans.fr/
${RELATIVE_VIDEO_PATH}    ./assets/fakecamfeed_cortez.mjpeg
${ANIMATED_PATH}    ./assets/animated.gif
# Browser to run the suite on: "chrome" (default) or "safari". Override with --variable BROWSER:safari.
# Always read it through "Browser Is Chrome" rather than comparing the string directly.
${BROWSER}    chrome
# Marker image uploaded by "Provide Marker Image" on Safari, which has no fake camera: a frame of the same
# fakecamfeed_cortez feed Chrome's fake camera streams, so marker quality stays comparable.
${SAFARI_MARKER_IMAGE}    ${EXECDIR}/assets/fakecamfeed_cortez.png
# Human-readable reason for each "safari-skip:<reason>" test tag, reported by "Skip Chrome-Only Test On Safari".
# Keep in sync with SKIP_REASONS in tools/safari_compatibility.py.
&{SAFARI_SKIP_REASONS}
...    cdp-network=uses Chrome DevTools Protocol network emulation (Go Offline / Set Network Speed)
...    cdp-state=continues a browser session that an earlier test took offline or throttled via CDP
...    offline-suite=suite exercises offline behaviour, which needs CDP network emulation
...    concurrent-browsers=needs two concurrent browser sessions; safaridriver allows only one
...    microphone=records from the microphone; Safari has no fake microphone
...    camera-todo=needs a camera snap; the Safari upload sequence for this activity type is not yet determined
...    camera-detection=asserts marker detection, which needs a live camera feed
...    onboarding-camera=onboarding tour steps target the camera capture controls
...    session-of-skipped=continues the browser session of a test that is skipped on Safari


*** Keywords ***
Bypass https alert
    [Documentation]    passe l'alerte en cas de certificat https invalide. Chrome-only: "details-button"/"proceed-link" are the ids of Chrome's own certificate interstitial page, which Safari does not have. Currently unused.
    Sleep    2
    Click Element    id=details-button
    Sleep    2
    Click Element    id=proceed-link

Set Chrome Options
    [Documentation]    Défini les paramètres du navigateur au besoin décommenter la ligne pour utiliser un flux caméra fictif
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${options}    add_argument    --use-fake-ui-for-media-stream
    Call Method    ${options}    add_argument    --use-fake-device-for-media-stream    #display a fake video if the machine doesnt have any camera
    Call Method    ${options}    add_argument    --use-file-for-fake-video-capture\=${EXECDIR}/assets/fakecamfeed_cortez.y4m
    Call Method    ${options}    add_argument    --use-file-for-fake-audio-capture\=${EXECDIR}/assets/moo1.wav    #plays this wav file as the fake microphone input
    ${prefs}=    Create Dictionary
    ...    profile.default_content_setting_values.media_stream_camera=1
    ...    profile.default_content_setting_values.media_stream_mic=1
    ...    credentials_enable_service=${False}
    ...    profile.password_manager_enabled=${False}
    ...    profile.password_manager_leak_detection=${False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${options}    add_argument    --disable-features\=PasswordLeakDetection,LeakDetectionUnauthenticated,PasswordChange
    RETURN    ${options}

Validate Browser Variable
    [Documentation]    Normalise ${BROWSER} to lower case and fail fast unless it is "chrome" or "safari", so a typo in --variable BROWSER:... stops the run with a clear message instead of silently falling back to a default. Returns the normalised value.
    ${browser}=    Evaluate    str($BROWSER).strip().lower()
    IF    $browser not in ('chrome', 'safari')
        Fail    Unsupported BROWSER '${BROWSER}': use --variable BROWSER:chrome (default) or --variable BROWSER:safari.
    END
    Set Global Variable    ${BROWSER}    ${browser}
    RETURN    ${browser}

Browser Is Chrome
    [Documentation]    Return ${True} when the suite runs on Chrome (see ${BROWSER}), ${False} on Safari. The single place browser-specific branches test the browser - keywords call this instead of comparing ${BROWSER} themselves.
    ${browser}=    Validate Browser Variable
    RETURN    ${{ $browser == 'chrome' }}

Skip Chrome-Only Test On Safari
    [Documentation]    Used as "Test Setup" by every suite that contains tests tagged "chrome-only". No-op on Chrome. On any other browser, SKIPs a "chrome-only" test with the reason(s) given by its "safari-skip:<reason>" tags (see ${SAFARI_SKIP_REASONS} and SAFARI_COMPATIBILITY.md). Safari runs normally exclude these tests with "--exclude chrome-only"; this makes them report a clear SKIP instead of a confusing FAIL if that flag is forgotten - including the chained tests (e.g. "Select Type - Slow 3G") that never call a CDP keyword themselves but continue a session an earlier test throttled.
    ${is_chrome}=    Browser Is Chrome
    IF    ${is_chrome} or 'chrome-only' not in $TEST_TAGS    RETURN
    ${reasons}=    Create List
    FOR    ${tag}    IN    @{TEST_TAGS}
        IF    $tag.startswith('safari-skip:')
            ${key}=    Evaluate    $tag.split(':', 1)[1]
            ${reason}=    Get From Dictionary    ${SAFARI_SKIP_REASONS}    ${key}    default=${key}
            Append To List    ${reasons}    ${reason}
        END
    END
    ${reason_text}=    Evaluate    '; '.join($reasons) or 'tagged chrome-only'
    Skip    Not supported on ${BROWSER}: ${reason_text}

Open MIXAP Browser
    [Documentation]    Open ${URL} in the browser selected by ${BROWSER}. Shared by every "Open Web Application*" keyword, which keep their own post-open steps. On Chrome this is exactly the historical behaviour: with ${fake_media} (the default) Chrome gets "Set Chrome Options" (fake camera/mic feed, auto-granted permissions); without it, plain Chrome. On Safari there is no options object and no fake media (see "Provide Marker Image" for how the camera is replaced), and safaridriver allows only ONE WebDriver session per machine, so any session still open (e.g. left behind by a failed test) is closed first - otherwise "Open Browser" itself would fail - and the window is maximized like the Chrome flows do.
    [Arguments]    ${alias}=${None}    ${fake_media}=${True}
    ${is_chrome}=    Browser Is Chrome
    IF    ${is_chrome} and ${fake_media}
        ${chrome_options}=    Set Chrome Options
        Open Browser    ${URL}    chrome    options=${chrome_options}    alias=${alias}
    ELSE IF    ${is_chrome}
        Open Browser    ${URL}    chrome    alias=${alias}
    ELSE
        Close All Browsers
        Open Browser    ${URL}    safari    alias=${alias}
        Maximize Browser Window
    END

Open Web Application
    [Documentation]    ouvre le site avec le navigateur choisi par ${BROWSER} (chrome par défaut, avec flux caméra/micro fictif) après avoir fermé tous les navigateurs ouverts - voir "Open MIXAP Browser"
    Close All Browsers
    Open MIXAP Browser
    Wait Until Keyword Succeeds    10s    1s    Title Should Be    MIXAP
    Wait Until Element Is Visible    xpath=//button[text()='New activity']
    Suppress All Onboarding Tours

Open Web Application with alias
    [Documentation]    ouvre le site avec le navigateur choisi par ${BROWSER} et avec un alias en paramètres - voir "Open MIXAP Browser". Sur Safari, une seule session est possible : les suites qui gardent deux navigateurs ouverts (043, 049, 054) sont donc "chrome-only".
    [Arguments]    ${alias}
    Open MIXAP Browser    alias=${alias}
    Wait Until Keyword Succeeds    10s    1s    Title Should Be    MIXAP
    Wait Until Element Is Visible    xpath=//button[text()='New activity']
    Suppress All Onboarding Tours

Open Web Application without closing
    [Documentation]    ouvre le site avec le navigateur choisi par ${BROWSER} sans fermer les navigateurs déjà ouverts (sur Chrome) - voir "Open MIXAP Browser", qui ferme quand même l'éventuelle session restante sur Safari puisqu'une seule session y est possible
    Open MIXAP Browser
    Wait Until Keyword Succeeds    10s    1s    Title Should Be    MIXAP
    Wait Until Element Is Visible    xpath=//button[text()='New activity']
    Suppress All Onboarding Tours

Open Web Application Without Fake Media
    [Documentation]    Open the site without fake camera/mic options: plain Chrome, or Safari (which never has fake media) - see "Open MIXAP Browser". Used by tests that only need to confirm the app shell loads and don't drive the camera-dependent activity flows.
    Open MIXAP Browser    fake_media=${False}
    Maximize Browser Window

Create Activity
    [Documentation]    clic sur le bouton création d'activité. Clicked via JavaScript to avoid "element click intercepted" failures from transient overlays (tooltips, badges) near the top of the page.
    Wait Until Element Is Visible    xpath=//button[@class='home__new-activity-btn' and not(contains(@class, 'home__import-btn'))]    15s
    Execute Javascript    document.evaluate("//button[@class='home__new-activity-btn' and not(contains(@class, 'home__import-btn'))]", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
    Wait Until Element Is Visible    xpath=//div[@class='activity-menu__grid']

Create Path
    [Documentation]    clic sur le bouton création de parcours. Clicked via JavaScript to avoid "element click intercepted" failures from transient overlays (tooltips, badges) near the top of the page - this button shares the same "home__new-activity-btn" base class as "New activity", which is why the interception error can look like it's about the wrong button.
    Wait Until Element Is Visible    xpath=//button[text()='New learning path']    15s
    Execute Javascript    document.evaluate("//button[text()='New learning path']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
    Wait Until Element Is Visible    xpath=//div[h3[text()='Free Exploration Path']]

Next button
    [Documentation]    clic sur le bouton suivant en bas a droite de l'application pour passer a l'étape suivante. Verified live against the app source ("Editor.tsx"): the classes "ant-btn-primary editor__nav-button editor__nav-button--primary" are the real, stable ones - the "css-XXXXXX" hash also present on the element is an Ant Design/emotion runtime style hash that regenerates on every app build/rebuild, so it must never be baked into a xpath "contains()" match (this had gone stale and was breaking the keyword before this fix). Also waits for the button to be ENABLED, not just visible: since the preprod app build of 2026-10-02, saving the marker photo starts the marker compilation in the background right away, and during it this same button turns into a disabled "Preparing marker… N%" loading button (~14s locally, longer on slower CI machines). Clicking it then is a silent no-op - the wizard never advances and "Validation button" times out waiting for the marker-features modal (this broke every marker-based test, confirmed live). The generous timeout covers slow machines; when the button is already enabled (every other step) the wait returns immediately.
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'ant-btn-primary') and contains(@class, 'editor__nav-button') and contains(@class, 'editor__nav-button--primary')]    10s
    Wait Until Element Is Enabled    xpath=//button[contains(@class, 'ant-btn-primary') and contains(@class, 'editor__nav-button') and contains(@class, 'editor__nav-button--primary')]    120s
    Click Element    xpath=//button[contains(@class, 'ant-btn-primary') and contains(@class, 'editor__nav-button') and contains(@class, 'editor__nav-button--primary')]

Snap the background
    [Documentation]    take the photo of the background used to display medias on
    Sleep    2s
    #Click Element    xpath=//button[div/div[text()='Cliquer ici pour prendre une photo.']]
    Wait Until Element Is Visible    xpath=//span[text()='Take a photo']
    Click Element    xpath=//span[text()='Take a photo']
    Sleep    5s
    Wait Until Element Is Visible    xpath=//button[.//span[text()='Snap']]    20s
    Click Element    xpath=//button[.//span[text()='Snap']]

Use template image
    [Documentation]    use a template image instead of taking a photo
    Sleep    2s
    Wait Until Element Is Visible    xpath=//span[text()='upload image']
    Choose File Robust    xpath=//input[@type='file']    ${EXECDIR}/assets/animated.gif
    
Provide Marker Image
    [Documentation]    Provide the marker (background) image on the marker step of the activity wizard. On Chrome this is exactly the historical camera flow: "Snap the background" (Chrome's fake camera streams assets/fakecamfeed_cortez.y4m), ${settle} of waiting, then "Validate the image". Safari has no fake camera, so there it uploads ${SAFARI_MARKER_IMAGE} instead through the wizard's "upload image" control - the same path "Use template image" takes. The upload path has NO "Validate the image" step: the uploaded image goes straight to compilation, so callers continue with "Next button" / "Validation button" exactly as after the snap (evidenced for "Augmented activity" by 051_empty_animated_augment.robot and for "Search and Find" by "Create failed search and find activity"). For any other ${activity_type} the Safari step sequence has not been determined yet (TODO, see SAFARI_COMPATIBILITY.md), so the test SKIPs rather than guessing.
    [Arguments]    ${activity_type}    ${settle}=2s
    ${is_chrome}=    Browser Is Chrome
    IF    ${is_chrome}
        Snap the background
        Sleep    ${settle}
        Validate the image
    ELSE IF    $activity_type in ('Augmented activity', 'Search and Find')
        Sleep    2s
        Wait Until Element Is Visible    xpath=//span[text()='upload image']
        Choose File Robust    xpath=//input[@type='file']    ${SAFARI_MARKER_IMAGE}
    ELSE
        Skip    Marker image on ${BROWSER}: no fake camera, and the upload sequence for "${activity_type}" has not been determined yet (TODO)
    END

Choose File Robust
    [Documentation]    "Choose File" for the app's upload inputs, most of which are Ant Design "Upload" components whose underlying "input[type=file]" is intentionally CSS-hidden (see "Add Audio To Augmentation" / "Add 3D Object To Augmentation"). On Chrome this is exactly a plain "Choose File" - ChromeDriver accepts file paths on hidden inputs. On Safari, safaridriver can reject sending keys to a non-interactable element (ElementNotInteractable), so the input is first made interactable via JavaScript (display, visibility, opacity, and a 1px size if it renders at zero width/height) - it stays a real file input, so the app's own onChange handler still receives the file. UNVERIFIED on Safari: not yet executed there (tests using it are tagged "safari-unverified").
    [Arguments]    ${locator}    ${file_path}
    ${is_chrome}=    Browser Is Chrome
    IF    ${is_chrome}
        Choose File    ${locator}    ${file_path}
    ELSE
        ${input}=    Get WebElement    ${locator}
        Execute Javascript    var el = arguments[0]; el.style.display = 'block'; el.style.visibility = 'visible'; el.style.opacity = '1'; if (el.offsetWidth === 0) { el.style.width = '1px'; } if (el.offsetHeight === 0) { el.style.height = '1px'; }    ARGUMENTS    ${input}
        Choose File    ${input}    ${file_path}
    END

Select Activity Type
    [Documentation]    Select the activity type using a parameter
    [Arguments]    ${activity_type}
    Wait Until Element Is Visible    xpath=//div[h3[text()='${activity_type}']]
    #Click Element    xpath=//div[h3[text()='${activity_type}']]
    #Click element using JavaScript to avoid issues with overlapping elements
    Execute JavaScript    Array.from(document.querySelectorAll("h3.activity-menu__card-title")).find(el => el.textContent.trim() === "${activity_type}").click();
    Wait Until Element Is Visible    xpath=//input[contains(@class, 'activity-view__input activity-view__input--title')]

Select Path Type
    [Documentation]    Select the path type using a parameter
    [Arguments]    ${path_type}
    Wait Until Element Is Visible    xpath=//div[h3[text()='${path_type}']]
    #Click Element    xpath=//div[h3[text()='${path_type}']]
    #Click element using JavaScript to avoid issues with overlapping elements
    Execute JavaScript    Array.from(document.querySelectorAll("h3.activity-menu__card-title")).find(el => el.textContent.trim() === "${path_type}").click();
    Wait Until Element Is Visible    xpath=//input[contains(@class, 'activity-view__input activity-view__input--title')]


Validate the image
    [Documentation]    click on the validation button to send the background image
    Wait Until Element Is Visible    xpath=//button[.//span[text()='Save']]     10s
    Click Element    xpath=//button[.//span[text()='Save']]

Validation button
    [Documentation]    click on the validation when rating the background picture. Verified live against the app source ("Board.tsx"): this is the "marker-features" modal's own Next button, scoped via its "marker-features__modal-footer" wrapper - it currently renders the exact same "editor__nav-button editor__nav-button--primary" classes and "Next" text as the main editor footer's regular Next button, so an unscoped match (the previous plain "button[text()='Next']") risks silently matching the wrong one instead of just going stale. Also waits for it to be enabled, not just visible: Board.tsx disables it while "compiling" (real marker-image analysis work) - clicking a merely-visible-but-still-disabled button is a silent no-op.
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'marker-features__modal-footer')]//button[contains(@class, 'editor__nav-button--primary')]    30s
    Wait Until Element Is Enabled    xpath=//div[contains(@class, 'marker-features__modal-footer')]//button[contains(@class, 'editor__nav-button--primary')]    15s
    Sleep    1s
    Click Element    xpath=//div[contains(@class, 'marker-features__modal-footer')]//button[contains(@class, 'editor__nav-button--primary')]

Wait for detection
    [Documentation]    wait for the augementation to be detected using the visibility of instructions
    Wait Until Element Is Not Visible     xpath=//span[contains(text(), 'Place the image in the frame')]    timeout=5s

Play Audio And Verify Playback
    [Documentation]    Click the audio tool's Play button and verify the audio is actually being played back. There is no HTML <audio>/<video> element to inspect (the app uses the Web Audio API), so playback is instead confirmed through the button's own state: its icon switches from "PlayArrowIcon" to "PauseIcon" while playing, and switches back to "PlayArrowIcon" on its own once the clip finishes - proving playback both started and ran to completion, not just that the click was accepted.
    [Arguments]    ${max_duration}=15s
    Click Element    xpath=//button[.//*[@data-testid='PlayArrowIcon']]
    Wait Until Element Is Visible    xpath=//button[.//*[@data-testid='PauseIcon']]    5s
    Wait Until Element Is Visible    xpath=//button[.//*[@data-testid='PlayArrowIcon']]    ${max_duration}

Wait For Detection Or Log Miss
    [Documentation]    Wait for the augmentation to be detected, tolerating a miss: the target is expected to occasionally still be undetected after 25s, so a timeout here is logged as an expected WARN instead of failing the test.
    ${status}    ${message}=    Run Keyword And Ignore Error    Wait for detection
    Run Keyword If    '${status}' == 'FAIL'    Log    ⚠️ Expected behavior: The element is still visible after 25s miss detection.    WARN

Augmentation Should Contain Text
    [Documentation]    Assert that the given text is rendered as an overlay within the currently open augmentation's canvas. Checks rendered DOM presence rather than reopening the text tool's editor to read it back, since clicking the "Text" toolbar button always adds a brand new text overlay instead of reselecting an existing one - there is no known way to reopen an existing text element for editing. Confirmed live (058_offline_text_edit_after_online_creation.robot): the "auras__html-container" class - already used for canvas-overlaid content in Information Layers activities, see "Check if Layer has content" - is shared by Augmented activities' text overlays too.
    [Arguments]    ${expected_text}
    Wait Until Element Is Visible    xpath=//*[contains(@class, 'auras__html-container') and contains(., '${expected_text}')]    15s

Get Augmentation Content Count
    [Documentation]    Return the number of rendered content overlays (text, image, audio, etc.) in the currently open augmentation's canvas, via the same "auras__html-container" wrapper class confirmed to hold rendered overlay content (see "Augmentation Should Contain Text" and "Check if Layer has content"). UNVERIFIED for image/audio specifically - confirmed so far only for text overlays and for images inside Information Layers activities (a different activity type). Use this to assert content accumulates as expected (e.g. count goes 0 -> 1 -> 2 as items are added) when there is no meaningful text value to match on, like for image or audio overlays.
    ${elements}=    Get WebElements    xpath=//*[contains(@class, 'auras__html-container')]
    ${count}=    Get Length    ${elements}
    RETURN    ${count}

Add Text To Augmentation
    [Documentation]    Add a text overlay to the currently open augmentation, using the provided text content. Set ${click_next}=${False} when reopening an already-published activity via "Reopen Activity Editor" - there is no further wizard step to advance to there, so close the editor explicitly afterwards (e.g. with "Click home button") instead.
    [Arguments]    ${text}=mon texte par défaut    ${click_next}=${True}
    Wait Until Element Is Visible    xpath=//button[@title='Text']    15s
    Click Element    xpath=//button[@title='Text']
    Wait Until Element Is Visible    xpath=//textarea[@placeholder='Edit your text...']    15s
    Click Element    xpath=//textarea[@placeholder='Edit your text...']
    Input Text    xpath=//textarea[@placeholder='Edit your text...']    ${text}
    IF    ${click_next}
        Next button
    END
    Sleep    2s

Add Image To Augmentation
    [Documentation]    Add an image overlay to the currently open augmentation, using the provided image file. Set ${click_next}=${False} to add more content afterward in the same session before finalizing - e.g. adding an image and then audio to the same activity, since the wizard's "Next" finishes the whole canvas step, not just this one item.
    [Arguments]    ${file_path}=${EXECDIR}/assets/annoter.png    ${click_next}=${True}
    Wait Until Element Is Visible    xpath=//button[@title='Image']    15s
    Click Element    xpath=//button[@title='Image']
    Wait Until Element Is Visible    xpath=//h5[contains(text(), 'Click to edit...')]    15s
    Click Element    xpath=//h5[contains(text(), 'Click to edit...')]
    Choose File Robust    xpath=//input[@type='file']    ${file_path}
    IF    ${click_next}
        Next button
    END

Add Video To Augmentation
    [Documentation]    Add a video overlay to the currently open augmentation, using the provided video file.
    [Arguments]    ${file_path}=${EXECDIR}/assets/pexels.mp4
    Wait Until Element Is Visible    xpath=//button[@title='Video']    15s
    Click Element    xpath=//button[@title='Video']
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'ant-typography') and contains(., 'Click to edit...')]    15s
    Click Element    xpath=//div[contains(@class, 'ant-typography') and contains(., 'Click to edit...')]
    Choose File Robust    xpath=//input[@type='file']    ${file_path}
    Next button

Add Sticker To Augmentation
    [Documentation]    Add the "arrow" stock sticker to the currently open augmentation.
    Wait Until Element Is Visible    xpath=//button[@title='Stickers']    15s
    Click Element    xpath=//button[@title='Stickers']
    Wait Until Element Is Visible    xpath=//img[contains(@src, 'image/arrow.png') and contains(@alt, 'Image 0')]    15s
    Click Element    xpath=//img[contains(@src, 'image/arrow.png') and contains(@alt, 'Image 0')]
    Next button

Add Audio To Augmentation
    [Documentation]    Add an audio overlay to the currently open augmentation, uploading a local sound file. Verified live against the app source ("PaletteButtonsBar.tsx" / "AAudio.tsx"): clicking the "Audio" toolbar button no longer opens an upload modal - it now behaves like "Add Sheet To Augmentation"'s Note tool, immediately placing an empty AAudio aura on the canvas whose controls popover (containing the file-upload button) is open by default ("visibleControls" state defaults to true in AAudio.tsx). The underlying "input[type=file]" (rendered by Ant Design's "Upload" component) is intentionally CSS-hidden and never becomes "visible" - confirmed live the popover's visible upload/mic/delete icons render immediately while the input stays hidden - so this waits for it to exist in the DOM ("Wait Until Page Contains Element"), not to become visible, before "Choose File Robust" (plain "Choose File" on Chrome, which works on hidden file inputs; on Safari it unhides the input first). There is no separate "confirm/validate" step - selecting the file alone updates the aura's content via the form's onChange.
    Wait Until Element Is Visible    xpath=//button[@title='Audio']    15s
    Click Element    xpath=//button[@title='Audio']
    Wait Until Page Contains Element    xpath=//input[@type='file']    15s
    Choose File Robust    xpath=//input[@type='file']    ${EXECDIR}/assets/1645.mp3
    Sleep    2s
    Next button

Add Sheet To Augmentation
    [Documentation]    Add a note/sheet overlay to the currently open augmentation, then edit its text. The "Note" tool's own panel only places an empty placeholder - the real editor doesn't open from there (this was the previous TODO: searching for an id-addressable edit target found nothing, because there isn't one). Confirmed live: clicking directly on the rendered overlay (the "auras__html-container" wrapper, same one used by "Get Augmentation Content Count") is what opens it, as a Tiptap/ProseMirror rich-text drawer prefilled with a default "Edit your content" heading. "Input Text" fully replaces that default content (SeleniumLibrary's clear() works fine on this contenteditable, confirmed live - no need for manual select-all/backspace). Confirmed the typed text persists across a reopen.
    [Arguments]    ${text}=ma note par défaut
    Wait Until Element Is Visible    xpath=//button[@title='Note']    15s
    Click Element    xpath=//button[@title='Note']
    Sleep    2
    Click Element    xpath=(//*[contains(@class, 'auras__html-container')])[last()]
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'tiptap ProseMirror')]    15s
    Click Element    xpath=//div[contains(@class, 'tiptap ProseMirror')]
    Input Text    xpath=//div[contains(@class, 'tiptap ProseMirror')]    ${text}
    Click Element    xpath=//button[contains(@class, 'ant-drawer-close')]
    Sleep    1s
    Next button

Add 3D Object To Augmentation
    [Documentation]    Add a 3D object overlay to the currently open augmentation, using the provided model file. Set ${click_next}=${False} to upload without advancing, e.g. when uploading several formats in a row and only the last one should proceed. Verified live against the app source ("A3d.tsx"): the "Click to edit..." text is just placeholder content shown inside the canvas element - clicking it used to work but now gets intercepted by the aura's own controls popover, which is open by default and already exposes the file-upload input directly, so this goes straight to "Choose File Robust" without clicking the placeholder (same fix as "Add Audio To Augmentation"). That underlying "input[type=file]" is intentionally CSS-hidden by Ant Design's "Upload" component and never becomes "visible", so this waits for it to exist in the DOM rather than to become visible - and uploads through "Choose File Robust", which unhides it first on Safari.
    [Arguments]    ${file_path}    ${click_next}=${True}
    Wait Until Element Is Visible    xpath=//button[@title='3D']    15s
    Click Element    xpath=//button[@title='3D']
    Wait Until Page Contains Element    xpath=//input[@type='file']    15s
    Choose File Robust    xpath=//input[@type='file']    ${file_path}
    Sleep    2
    IF    ${click_next}
        Next button
    END

Add Link To Augmentation
    [Documentation]    Add a link overlay to the currently open augmentation, pointing to the provided URL. Verified live against the app source ("ALink.tsx" / "InputLink.tsx"): clicking the "Link" toolbar button places an ALink aura directly on the canvas (same place-on-canvas pattern as Audio/Note) whose controls popover is open by default - there is no "Click to edit..." placeholder step any more. The popover's first control is a plain icon-only button (no title/aria-label to key off - "(//form[@id='basic']//button)[1]" targets it by its known position, since "InputLink" is always the first item in ALink's options array) which itself opens a NESTED popover containing the real URL input. That input commits via Enter ("onPressEnter" in "InputLink.tsx") - simpler and more robust than locating its icon-only confirm button.
    [Arguments]    ${url}=google.com/
    Wait Until Element Is Visible    xpath=//button[@title='Link']    15s
    Click Element    xpath=//button[@title='Link']
    Sleep    2s
    Wait Until Element Is Visible    xpath=(//form[@id='basic']//button)[1]    15s
    Click Element    xpath=(//form[@id='basic']//button)[1]
    Wait Until Element Is Visible    xpath=//input[@placeholder='Enter URL']    15s
    Input Text    xpath=//input[@placeholder='Enter URL']    ${url}
    Press Keys    xpath=//input[@placeholder='Enter URL']    RETURN
    Sleep    1s
    Next button

Add AI Generated Text To Augmentation
    [Documentation]    Open the AI generation tool and generate a text overlay from the provided prompt.
    [Arguments]    ${prompt}=Generate a little poem about a cat and a dog playing together in the park.
    Wait Until Element Is Visible    xpath=//button[@title='AI']    15s
    Click Element    xpath=//button[@title='AI']
    Wait Until Element Is Visible    xpath=//button[@aria-label='Text']    15s
    Execute JavaScript    document.querySelector("button.ant-btn-icon-only[aria-label='Text']").click();
    Wait Until Element Is Visible    xpath=//input[contains(@class, 'ds-modal__input') and @placeholder='Ask or describe what to generate…']    5s
    Input Text    xpath=//input[contains(@class, 'ds-modal__input') and @placeholder='Ask or describe what to generate…']    ${prompt}
    Wait Until Element Is Visible    xpath=//button[@aria-label='Generate preview']    15s
    Click Element    xpath=//button[@aria-label='Generate preview']
    Wait Until Element Is Visible    xpath=//button[.//span[@aria-label='plus']]    15s
    Click Element    xpath=//button[.//span[@aria-label='plus']]
    Next button
    Sleep    2s

Add AI Generated Image To Augmentation
    [Documentation]    Open the AI generation tool and generate an image overlay from the provided prompt.
    [Arguments]    ${prompt}=Generate an image of a cat and a dog playing together in the park.
    Wait Until Element Is Visible    xpath=//button[@title='AI']    15s
    Click Element    xpath=//button[@title='AI']
    Wait Until Element Is Visible    xpath=//button[@aria-label='Image']    15s
    Execute JavaScript    document.querySelector("button.ant-btn-icon-only[aria-label='Image']").click();
    Wait Until Element Is Visible    xpath=//input[contains(@class, 'ds-modal__input') and @placeholder='Describe the image…']    5s
    Input Text    xpath=//input[contains(@class, 'ds-modal__input') and @placeholder='Describe the image…']    ${prompt}
    Wait Until Element Is Visible    xpath=//button[@aria-label='Generate preview']    15s
    Click Element    xpath=//button[@aria-label='Generate preview']
    Sleep    2s
    Wait Until Element Is Visible    xpath=//button[.//span[@aria-label='plus']]    30s
    Click Element    xpath=//button[.//span[@aria-label='plus']]
    Next button
    Sleep    2s

Add AI Generated Audio To Augmentation
    [Documentation]    Open the AI generation tool and generate a text-to-speech audio overlay from the provided text.
    [Arguments]    ${text}=Hello world !
    Wait Until Element Is Visible    xpath=//button[@title='AI']    15s
    Click Element    xpath=//button[@title='AI']
    Wait Until Element Is Visible    xpath=//button[@aria-label='Audio']    15s
    Execute JavaScript    document.querySelector("button.ant-btn-icon-only[aria-label='Audio']").click();
    Wait Until Element Is Visible    xpath=//input[contains(@class, 'ds-modal__input') and @placeholder='Type the text to speak…']    5s
    Input Text    xpath=//input[contains(@class, 'ds-modal__input') and @placeholder='Type the text to speak…']    ${text}
    Wait Until Element Is Visible    xpath=//button[@aria-label='Generate preview']    15s
    Click Element    xpath=//button[@aria-label='Generate preview']
    Sleep    2s
    Wait Until Element Is Visible    xpath=//button[.//span[@aria-label='plus']]    30s
    Click Element    xpath=//button[.//span[@aria-label='plus']]
    Next button
    Sleep    2s

Click home button
    [Documentation]    Click on the home button using the house icon
    Wait Until Page Contains Element    xpath=//button[contains(@class, 'editor__close-button')]    timeout=5s
    #Click Element    xpath=//button[contains(@class, 'editor__close-button')]
    #Click element using JavaScript to avoid issues with overlapping elements
    Execute JavaScript    document.querySelector("button.editor__close-button").click();

Click home button and discard draft
    [Documentation]    Click the editor's home/close button, then confirm the "Discard activity?" dialog that appears instead of navigating home directly when leaving an unsaved draft (see Editor.tsx's "handleClose": activities with "meta.isDraft" still set - e.g. a Guided/Auto-Triggered Path/Group not yet carried through to its final "Save" step - trigger this confirmation).
    Click home button
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'editor__discard-modal-button--danger')]    5s
    Click Element    xpath=//button[contains(@class, 'editor__discard-modal-button--danger')]

Add Tag to Activity
    [Documentation]    Add a tag to the activity using the provided tag name. Call this once per tag to attach more than one - verified live, it correctly handles: (1) the first tag on an activity (the trigger is an empty-state "editor__tags-chip" button) vs. any additional tag (once at least one tag exists, that button is replaced entirely by an "editor__activity-tag" chip showing the existing tag(s) - clicking it reopens the same "Tag your activity" panel with the same "Add label" option); and (2) a tag NAME that already exists as a label elsewhere in the account (e.g. attached to a different activity earlier in the same session) vs. a genuinely new one - the panel shows already-existing labels as directly clickable "Select tags" chips, and clicking "Add label" then typing/entering a name that matches one of those existing chips does NOT attach it (silently does nothing) - the existing chip must be clicked directly instead. A caller that only ever uses the "Add label" input path will silently fail to attach any tag whose name was already used earlier in the same run.
    [Arguments]    ${tag_name}
    ${has_existing_tag}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//button[contains(@class, 'editor__activity-tag')]    2s
    IF    ${has_existing_tag}
        Click Element    xpath=(//button[contains(@class, 'editor__activity-tag')])[1]
    ELSE
        Wait Until Element Is Visible    xpath=//button[contains(@class, 'editor__tags-chip')]    5s
        Click Element    xpath=//button[contains(@class, 'editor__tags-chip')]
    END
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'labels-panel')]    5s
    ${tag_already_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//div[contains(@class, 'labels-panel__chip labels-panel__chip--clickable')]//span[text()='${tag_name}']    2s
    IF    ${tag_already_exists}
        Click Element    xpath=//div[contains(@class, 'labels-panel__chip labels-panel__chip--clickable')]//span[text()='${tag_name}']
    ELSE
        Wait Until Element Is Visible    xpath=//button[contains(@aria-label, 'Add label')]
        Click Element    xpath=//button[contains(@aria-label, 'Add label')]
        Input Text    xpath=//input[contains(@class, 'labels-panel__add-name-input')]    ${tag_name}
        Press Keys    xpath=//input[contains(@class, 'labels-panel__add-name-input')]    RETURN
    END
    Click Element    xpath=//button[contains(@class, 'labels-panel__close')]

Delete Tag from Activity
    [Documentation]    Delete a tag from the activity using the provided tag name
    [Arguments]    ${tag_name}
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__labels-btn')]    5s
    Click Element    xpath=//button[contains(@class, 'home__labels-btn')]
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'labels-panel__chip-icon-btn')]    5s
    Click Element    xpath=//button[contains(@class, 'labels-panel__chip-icon-btn')]
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'confirmation-dialog__button')]    5s
    Click Element    xpath=//button[contains(@class, 'confirmation-dialog__button')]
    Click Element    xpath=//button[contains(@class, 'labels-panel__close')]

Edit Activity Title
    [Arguments]    ${title}
    Wait Until Element Is Visible    xpath=//input[contains(@class, 'activity-view__input--title')]    5s
    Input Text    xpath=//input[contains(@class, 'activity-view__input--title')]    ${title}
    Sleep    2    # Manually wait for the text to be updated

Edit Path Title
    [Documentation]    Paths and activities share the same title editor, so this just delegates to "Edit Activity Title".
    [Arguments]    ${title}
    Edit Activity Title    ${title}

Edit Activity Instructions
    [Arguments]    ${instructions}
    Wait Until Element Is Visible    xpath=//textarea[contains(@class, 'activity-view__input--instruction')]    5s
    Input Text    xpath=//textarea[contains(@class, 'activity-view__input--instruction')]    ${instructions}
    Sleep    2    # Manually wait for the text to be updated

Edit Path Instructions
    [Documentation]    Paths and activities share the same instructions editor, so this just delegates to "Edit Activity Instructions".
    [Arguments]    ${instructions}
    Edit Activity Instructions    ${instructions}

Edit Activity Description
    [Documentation]    Edit the activity description using the provided description text
    [Arguments]    ${description}
    Click Element    xpath=//span[@id='description_editor']/div[@role='button']
    Wait Until Element Is Visible    xpath=//textarea[not(contains(@style, 'visibility:hidden'))]    5s
    Execute JavaScript    document.querySelector("textarea:not([style*='visibility:hidden'])").value = "${description}";
    Press Keys    xpath=//textarea[not(contains(@style, 'visibility:hidden'))]    RETURN
    Sleep    2    # Manually wait for the text to be updated

Create empty augmented activity
    [Documentation]    Create an empty augmented activity with a title, snap the background and validate
    [Arguments]    ${title}
    Create Activity
    Select Activity Type    Augmented activity
    Next button
    Sleep    2s
    Edit Activity Title    ${title}
    Next button
    Sleep    2s
    Provide Marker Image    Augmented activity    settle=5s
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Next button
    Sleep    2s
    Wait For Detection Or Log Miss
    Click home button

Create empty validation
    [Documentation]    Create an empty validation with a title and instructions, snap the background and validate
    [Arguments]    ${title}    ${instructions}
    Create Activity
    Select Activity Type    Search and Find
    Next button
    Sleep    2s
    Edit Activity Title    ${title}
    Edit Activity Instructions    ${instructions}
    Next button
    Sleep    2s
    Provide Marker Image    Search and Find
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    2s
    Next button
    Sleep    5s
    Wait For Detection Or Log Miss
    Click home button

Create empty path
    [Documentation]    Create an empty path with a title and instructions. Defaults to "Free Exploration Path"; pass ${path_type} to create one of the other path types instead (e.g. "Auto-Triggered Path", "Guided Path").
    [Arguments]    ${title}=parcours numéro 1    ${instructions}=instruction relative au parcours numéro 1    ${path_type}=Free Exploration Path
    Create Path
    Select Path Type    ${path_type}
    Edit Path Title    ${title}
    Edit Path Instructions    ${instructions}
    Next button
    Sleep    2s
    Wait Until Element Is Visible    xpath=//div[h3[contains(@class, 'activity-card__title activity-card__title--large-light') and text()='${title}']]    15s

Go Offline
    [Documentation]    Set the browser to offline mode using Chrome DevTools Protocol (CDP). Chrome-only: on any other browser (see ${BROWSER}) this SKIPs the current test with an explicit reason instead of failing, since CDP does not exist there - tests that need it are tagged "chrome-only" (see SAFARI_COMPATIBILITY.md).
    ${is_chrome}=    Browser Is Chrome
    Skip If    not ${is_chrome}    Network emulation requires Chrome DevTools Protocol; not available on ${BROWSER}
    ${seleniumlib}    Get Library Instance    SeleniumLibrary
    VAR    ${webdriver}    ${seleniumlib.driver}
    # SetOffline
    VAR    ${novalue}    0
    ${novalue}    Convert to Integer    ${novalue}
    ${conditions}    Create Dictionary    offline=${True}    latency=${novalue}    downloadThroughput=${novalue}    uploadThroughput=${novalue}
    Call Method    ${webdriver}    execute_cdp_cmd    Network.emulateNetworkConditions    ${conditions}

Go Online
    [Documentation]    Set the browser to online mode using Chrome DevTools Protocol (CDP). Chrome-only: on any other browser (see ${BROWSER}) this SKIPs the current test with an explicit reason instead of failing, since CDP does not exist there - tests that need it are tagged "chrome-only" (see SAFARI_COMPATIBILITY.md).
    ${is_chrome}=    Browser Is Chrome
    Skip If    not ${is_chrome}    Network emulation requires Chrome DevTools Protocol; not available on ${BROWSER}
    ${seleniumlib}    Get Library Instance    SeleniumLibrary
    VAR    ${webdriver}    ${seleniumlib.driver}
    # SetOffline
    VAR    ${novalue}    0
    ${novalue}    Convert to Integer    ${novalue}
    ${conditions}    Create Dictionary    offline=${False}    latency=${novalue}    downloadThroughput=${novalue}    uploadThroughput=${novalue}
    Call Method    ${webdriver}    execute_cdp_cmd    Network.emulateNetworkConditions    ${conditions}

Set Network Speed
    [Documentation]    Throttle the network using Chrome DevTools Protocol (CDP), for testing behavior under a slow connection instead of going fully offline. Defaults roughly match Chrome DevTools' "Slow 3G" preset (2000ms latency, ~62.5 KB/s down/up). Call "Reset Network Speed" afterwards to remove the throttling. Chrome-only: on any other browser (see ${BROWSER}) this SKIPs the current test with an explicit reason instead of failing, since CDP does not exist there - tests that need it are tagged "chrome-only" (see SAFARI_COMPATIBILITY.md).
    [Arguments]    ${latency}=2000    ${download_throughput}=62500    ${upload_throughput}=62500
    ${is_chrome}=    Browser Is Chrome
    Skip If    not ${is_chrome}    Network emulation requires Chrome DevTools Protocol; not available on ${BROWSER}
    ${latency}=    Convert To Integer    ${latency}
    ${download_throughput}=    Convert To Integer    ${download_throughput}
    ${upload_throughput}=    Convert To Integer    ${upload_throughput}
    ${seleniumlib}=    Get Library Instance    SeleniumLibrary
    VAR    ${webdriver}    ${seleniumlib.driver}
    ${conditions}=    Create Dictionary    offline=${False}    latency=${latency}    downloadThroughput=${download_throughput}    uploadThroughput=${upload_throughput}
    Call Method    ${webdriver}    execute_cdp_cmd    Network.emulateNetworkConditions    ${conditions}

Reset Network Speed
    [Documentation]    Remove any network throttling applied via "Set Network Speed" or "Go Offline", restoring a normal, unthrottled connection. A throughput of -1 tells CDP not to limit that direction at all. Chrome-only: on any other browser (see ${BROWSER}) this SKIPs the current test with an explicit reason instead of failing, since CDP does not exist there - tests that need it are tagged "chrome-only" (see SAFARI_COMPATIBILITY.md).
    ${is_chrome}=    Browser Is Chrome
    Skip If    not ${is_chrome}    Network emulation requires Chrome DevTools Protocol; not available on ${BROWSER}
    ${seleniumlib}=    Get Library Instance    SeleniumLibrary
    VAR    ${webdriver}    ${seleniumlib.driver}
    ${conditions}=    Create Dictionary    offline=${False}    latency=${0}    downloadThroughput=${-1}    uploadThroughput=${-1}
    Call Method    ${webdriver}    execute_cdp_cmd    Network.emulateNetworkConditions    ${conditions}

Wait For Activity
    [Documentation]    Wait until the activity/path card identified by the provided title is visible on the home menu.
    [Arguments]    ${activity_title}    ${timeout}=15s
    Wait Until Element Is Visible    xpath=//div[h3[contains(@class, 'activity-card') and text()='${activity_title}']]    ${timeout}

Search For
    [Documentation]    Open the home menu's search box (if not already open) and replace its content with the given text, filtering the visible activity/path cards. Pass ${EMPTY} to clear the search. Verified live: "CTRL+a" does not actually select the existing text here (Input Text just appends after it), so the field is cleared with "Clear Element Text" instead - which can itself collapse the search box back to its closed icon state, so visibility is re-checked and the box re-opened before typing new text into it.
    [Arguments]    ${search_text}
    ${search_input}=    Set Variable    xpath=//input[@placeholder='Search activities...']
    ${input_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${search_input}    2s
    IF    not ${input_visible}
        Click Element    xpath=//button[contains(@class, 'home__search-btn')]
        Wait Until Element Is Visible    ${search_input}    5s
    END
    Click Element    xpath=//span[contains(@class, 'ant-input-suffix')]
    Click Element    xpath=//button[contains(@class, 'home__search-btn')]
    Sleep    1s
    IF    '${search_text}' != '${EMPTY}'
        ${still_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${search_input}    2s
        IF    not ${still_visible}
            Click Element    xpath=//button[contains(@class, 'home__search-btn')]
            Wait Until Element Is Visible    ${search_input}    5s
        END
        Input Text    ${search_input}    ${search_text}
    END
    Sleep    2s

Click Activity Card
    [Documentation]    Scroll to and click an activity card identified by its title. Retried by its caller since the layout can shift between the scroll and the click on large accounts.
    [Arguments]    ${activity_title}
    Scroll Element Into View    xpath=//div[h3[contains(@class, 'activity-card') and text()='${activity_title}']]
    Click Element    xpath=//div[h3[contains(@class, 'activity-card') and text()='${activity_title}']]

Add Activity to Path
    [Documentation]    Add an activity to the path using the provided activity title. When ${path_title} is given, the drop target is scoped to that specific path's card, which matters when the account has more than one path visible on screen. Safari: runs the same Selenium action chain (no JavaScript fallback) - UNVERIFIED there, since which events the app listens for (pointer/mouse vs HTML5 drag-and-drop) is not confirmed; callers are tagged "safari-unverified".
    [Arguments]    ${activity_title}    ${path_title}=${EMPTY}
    Wait Until Element Is Visible    xpath=//div[h3[contains(@class, 'activity-card') and text()='${activity_title}']]    15s
    Wait Until Keyword Succeeds    3x    2s    Click Activity Card    ${activity_title}
    IF    '${path_title}' != '${EMPTY}'
        ${drop_target}=    Set Variable    xpath=//h3[contains(@class, 'activity-card') and text()='${path_title}']/ancestor::div[contains(@class, 'activity-card--group')][1]/*[contains(@class,'activity-card__content')]
    ELSE
        ${drop_target}=    Set Variable    xpath=//*[contains(@class,'activity-card--group')]/*[contains(@class,'activity-card__content')]
    END
    Drag And Drop    xpath=//div[h3[contains(@class, 'activity-card') and text()='${activity_title}']]    ${drop_target}
    Sleep    4s

Get Card Data Id
    [Documentation]    Return the unique "data-id" of the activity/path card identified by the provided title. Capture this right after creating/duplicating a card so later steps can target it precisely by id instead of matching by title, which can collide with duplicates or stale data from earlier runs.
    [Arguments]    ${card_title}
    ${card_id}=    Get Element Attribute    xpath=//h3[contains(@class, 'activity-card') and text()='${card_title}']/ancestor::div[@data-id][1]    data-id
    RETURN    ${card_id}

Click Activity Card By Id
    [Documentation]    Scroll to and click an activity/path card identified by its data-id. Retried by its caller since the layout can shift on large accounts.
    [Arguments]    ${card_id}
    ${card}=    Set Variable    xpath=//div[contains(@class, 'activity-card') and @data-id='${card_id}']
    Scroll Element Into View    ${card}
    Click Element    ${card}

Add Activity to Path By Id
    [Documentation]    Add an activity to a path, both identified by their unique "data-id" rather than title text. Immune to duplicate or stale-data titles anywhere else on the page. The drag is started from the card's title-wrapper (not the full card) because Selenium's synthetic drag grabs the element's center point, and the full card's center can land on an action button (like/sync/menu) instead of empty space, silently breaking the drag. The drop itself is done as Mouse Down / Mouse Over / Sleep / Mouse Up instead of the single-shot "Drag And Drop" keyword, because the app needs a brief hover over the drop zone to register the dragover state before the mouse is released - "Drag And Drop" releases immediately after arriving, which is too fast for it to pick up. Safari: runs the same Selenium action chain (no JavaScript fallback) - UNVERIFIED there, since which events the app listens for (pointer/mouse vs HTML5 drag-and-drop) is not confirmed; callers are tagged "safari-unverified".
    [Arguments]    ${activity_id}    ${path_id}
    ${activity_card}=    Set Variable    xpath=//div[contains(@class, 'activity-card') and @data-id='${activity_id}']
    ${drag_source}=    Set Variable    ${activity_card}//div[contains(@class,'activity-card__title-wrapper')]
    ${drop_target}=    Set Variable    xpath=//div[contains(@class, 'activity-card') and @data-id='${path_id}']/*[contains(@class,'activity-card__content')]
    Wait Until Element Is Visible    ${activity_card}    15s
    Wait Until Keyword Succeeds    3x    2s    Click Activity Card By Id    ${activity_id}
    Mouse Down    ${drag_source}
    Mouse Over    ${drop_target}
    Sleep    1s
    Mouse Up    ${drop_target}
    Sleep    4s

Open Path Content Drawer
    [Documentation]    Open the path's content management drawer, identified by its "data-id". Click the card's title-wrapper (not the title-arrow-button, which instead launches the AR player) to reach it.
    [Arguments]    ${path_id}
    ${path_card}=    Set Variable    xpath=//div[contains(@class, 'activity-card') and @data-id='${path_id}']
    Scroll Element Into View    ${path_card}
    Click Element    ${path_card}//div[contains(@class,'activity-card__title-wrapper')]
    Wait Until Element Is Visible    xpath=//div[contains(@class,'path-slider__content')]    15s

Close Path Content Drawer
    [Documentation]    Close the path content drawer opened by "Open Path Content Drawer". Waits a few seconds after closing since the home grid re-renders when the drawer closes, and interacting with cards too soon can find them momentarily missing.
    Click Element    xpath=//button[contains(@class,'path-slider__close-button')]
    Sleep    3s

Path Should Contain Activities
    [Documentation]    Assert that every activity id in the given list is present in the currently open path content drawer. Call "Open Path Content Drawer" first. Verified live: each mini-card in the drawer carries "data-id" on two nested elements (the "path-slider__masonry-item" wrapper AND the inner "activity-card" div) - matching bare "//*[@data-id=...]" double-counts every card, so this scopes to the inner "activity-card" div only, one match per card.
    [Arguments]    ${activity_ids}
    ${expected_count}=    Get Length    ${activity_ids}
    ${id_conditions}=    Evaluate    " or ".join(["@data-id='%s'" % i for i in $activity_ids])
    ${actual_count}=    Get Element Count    xpath=//div[contains(@class,'path-slider__content')]//div[contains(@class,'activity-card') and (${id_conditions})]
    Should Be Equal As Integers    ${actual_count}    ${expected_count}    msg=Expected ${expected_count} activities in the path but found ${actual_count}

Get Missing Activity Ids
    [Documentation]    Return the subset of the given activity ids that are NOT present in the currently open path content drawer. Call "Open Path Content Drawer" first. Same double-"data-id" caveat as "Path Should Contain Activities" - scoped to the inner "activity-card" div only.
    [Arguments]    ${activity_ids}
    ${missing}=    Create List
    FOR    ${activity_id}    IN    @{activity_ids}
        ${found_count}=    Get Element Count    xpath=//div[contains(@class,'path-slider__content')]//div[contains(@class,'activity-card') and @data-id='${activity_id}']
        IF    ${found_count} == 0
            Append To List    ${missing}    ${activity_id}
        END
    END
    RETURN    ${missing}

Remove Activity From Path By Id
    [Documentation]    Remove an activity from an already-open path content drawer WITHOUT deleting the activity itself, identified by its "data-id". The real mechanism (non-obvious, confirmed live): click the mini-card's title-wrapper (not the whole card - its bounding-box center overlaps the like/sync action buttons, same pitfall as "Add Activity to Path By Id") to select it, which reveals a floating "N selected / Remove / Clear" action bar at the bottom of the drawer; click its "Remove" button. No confirmation dialog appears. Verified live: the activity is only detached from this path - it still exists as an independent card on the home grid afterwards. Contrast with "Delete Activity From Path Drawer By Id", whose "Delete" menu item instead performs a full, irreversible deletion of the activity everywhere.
    [Arguments]    ${activity_id}
    ${mini_card}=    Set Variable    xpath=//div[contains(@class,'path-slider__content')]//*[@data-id='${activity_id}']
    Wait Until Element Is Visible    ${mini_card}    10s
    Scroll Element Into View    ${mini_card}
    Click Element    ${mini_card}//div[contains(@class,'activity-card__title-wrapper')]
    Wait Until Element Is Visible    xpath=//button[contains(@class,'path-slider__selection-floating-remove')]    5s
    Click Element    xpath=//button[contains(@class,'path-slider__selection-floating-remove')]
    Sleep    2s

Delete Activity From Path Drawer By Id
    [Documentation]    Delete an activity from within an already-open path content drawer, identified by its "data-id". This is a full, irreversible deletion of the activity everywhere (confirmed via its "Are you sure you want to delete this activity? This action cannot be undone." dialog, and the activity disappearing from the home grid afterwards, not just from the path) - the SAME action as "Delete Activity Or Path" on the home grid, just reachable from inside a path. If you want to detach an activity from a path while keeping it, use "Remove Activity From Path By Id" instead. Follows the same Ant Design stale-dropdown-menu pattern as "Delete Activity Or Path": filters ".ant-dropdown-menu-title-content" nodes by visible text and offsetParent, since Ant Design leaves prior dropdown instances mounted-but-hidden.
    [Arguments]    ${activity_id}
    ${mini_card}=    Set Variable    xpath=//div[contains(@class,'path-slider__content')]//*[@data-id='${activity_id}']
    Wait Until Element Is Visible    ${mini_card}    10s
    Scroll Element Into View    ${mini_card}
    Wait Until Element Is Visible    ${mini_card}//button[contains(@class,'menu')]    5s
    Click Element    ${mini_card}//button[contains(@class,'menu')]
    Sleep    1s
    ${clicked}=    Execute Javascript    var items=[...document.querySelectorAll('.ant-dropdown-menu-title-content')].filter(function(el){return el.textContent.trim()==='Delete' && el.offsetParent!==null;}); if(items.length===0){return false;} items[0].click(); return true;
    Should Be True    ${clicked}    Could not find a visible "Delete" menu item on the path drawer mini-card
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'confirmation-dialog__footer')]//button[text()='Delete']    15s
    Click Element    xpath=//div[contains(@class, 'confirmation-dialog__footer')]//button[text()='Delete']
    Sleep    2s

Sign In
    [Documentation]    Sign in to the application using the provided email and password. Waits out the "loading-blocker" overlay before returning - the shared test accounts accumulate a lot of activities/paths across repeated runs, and the initial sync after login can take a while, during which the overlay intercepts clicks on anything underneath it (e.g. "New activity").
    [Arguments]    ${email}    ${password}
    Wait Until Element Is Visible    xpath=//button[.//span[contains(@class, 'anticon anticon-user')]]    30s
    Click Element    xpath=//button[.//span[contains(@class, 'anticon anticon-user')]]
    Wait Until Element Is Visible    xpath=//button[text()='Login']    30s
    Click Element    xpath=//button[text()='Login']
    Input Text    xpath=//input[@placeholder='you@company.com']    ${email}
    Input Text    xpath=//input[@placeholder='••••••••']    ${password}
    Click Element    xpath=//button[text()='Continue']
    Sleep    5s
    Wait Until Element Is Not Visible    xpath=//div[contains(@class, 'loading-blocker__overlay')]    60s

Sign Up
    [Documentation]    Sign up for a new account using the provided username, email and password. Waits are generous (30s) on the two panel-opening steps since under "Set Network Speed" throttling the login/signup panel can take a while to render, and this is called much more often now that most tests sign up a fresh random account instead of signing into a shared one.
    [Arguments]    ${username}    ${email}    ${password}
    Wait Until Element Is Visible    xpath=//button[.//span[contains(@class, 'anticon anticon-user')]]    30s
    Click Element    xpath=//button[.//span[contains(@class, 'anticon anticon-user')]]
    Wait Until Element Is Visible    xpath=//button[text()='Sign up']    30s
    Click Element    xpath=//button[text()='Sign up']
    Wait Until Element Is Visible    xpath=//input[@placeholder='your_username']    15s
    Input Text    xpath=//input[@placeholder='your_username']    ${username}
    Input Text    xpath=//input[@placeholder='you@company.com']    ${email}
    Input Text    xpath=//input[@placeholder='••••••••']    ${password}
    Click Element    xpath=//button[text()='Create account']
    Sleep    5s

Sign Out
    [Documentation]    Sign out of the currently signed-in account via the header user menu, confirming the "Sign out?" dialog that follows. Used to exercise the sign-in flow against a freshly signed-up account instead of a shared one: sign up, sign out, then sign back in with the same credentials.
    Wait Until Element Is Visible    xpath=//button[.//span[contains(@class, 'anticon anticon-user')]]    15s
    Click Element    xpath=//button[.//span[contains(@class, 'anticon anticon-user')]]
    Wait Until Element Is Visible    xpath=//span[contains(@class, 'ant-dropdown-menu-title-content') and text()='Sign out']    5s
    ${clicked}=    Execute Javascript    var items=[...document.querySelectorAll('.ant-dropdown-menu-title-content')].filter(function(el){return el.textContent.trim()==='Sign out' && el.offsetParent!==null;}); if(items.length===0){return false;} items[0].click(); return true;
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'confirmation-dialog__button--danger')]    5s
    Click Element    xpath=//button[contains(@class, 'confirmation-dialog__button--danger')]
    Wait Until Element Is Not Visible    xpath=//button[contains(@class, 'confirmation-dialog__button--danger')]    5s

Delete Account
    [Documentation]    Permanently delete the currently signed-in account, via the header user menu's "Profile" page > "Danger zone" > "Delete account", confirming with the account's own password in the follow-up dialog. Irreversible: deletes the account, profile, and all activities/paths it owns in the cloud. New as of this app update - previously there was no self-service account-deletion feature at all. Use this to clean up a throwaway account created with "Sign Up" instead of leaving it orphaned forever. Verified live: the confirm button starts disabled and only becomes clickable once a password has been typed into the "Current password" field; both the trigger button and the dialog's confirm button share the literal text "Delete account", so the confirm step is scoped to the dialog's own "confirmation-dialog__button--danger" class to avoid ambiguity. The trigger button is clicked via JavaScript rather than "Click Element" - confirmed live (reproduced via 031_import.robot's "Launch imported activity" flow) that a transient Ant Design toast ("ant-notification-notice-wrapper", e.g. a sync-status notification popping up right as the profile page loads) can sit on top of it and throw "element click intercepted" with a native click.
    [Arguments]    ${password}
    Wait Until Element Is Visible    xpath=//button[.//span[contains(@class, 'anticon anticon-user')]]    15s
    Click Element    xpath=//button[.//span[contains(@class, 'anticon anticon-user')]]
    Wait Until Element Is Visible    xpath=//span[contains(@class, 'ant-dropdown-menu-title-content') and text()='Profile']    5s
    ${clicked}=    Execute Javascript    var items=[...document.querySelectorAll('.ant-dropdown-menu-title-content')].filter(function(el){return el.textContent.trim()==='Profile' && el.offsetParent!==null;}); if(items.length===0){return false;} items[0].click(); return true;
    Should Be True    ${clicked}    Could not find a visible "Profile" menu item
    Wait Until Element Is Visible    xpath=//button[text()='Delete account']    10s
    Scroll Element Into View    xpath=//button[text()='Delete account']
    ${clicked}=    Execute Javascript    var items=[...document.querySelectorAll('button')].filter(function(el){return el.textContent.trim()==='Delete account' && el.offsetParent!==null;}); if(items.length===0){return false;} items[0].click(); return true;
    Should Be True    ${clicked}    Could not find a visible "Delete account" trigger button
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'confirmation-dialog')]//input[contains(@class, 'profile__input')]    5s
    Click Element    xpath=//div[contains(@class, 'confirmation-dialog')]//input[contains(@class, 'profile__input')]
    Input Text    xpath=//div[contains(@class, 'confirmation-dialog')]//input[contains(@class, 'profile__input')]    ${password}
    Wait Until Element Is Enabled    xpath=//button[contains(@class, 'confirmation-dialog__button--danger')]    5s
    Click Element    xpath=//button[contains(@class, 'confirmation-dialog__button--danger')]
    Wait Until Element Is Not Visible    xpath=//button[contains(@class, 'confirmation-dialog__button--danger')]    15s

Open Import Modal
    [Documentation]    Click the import button and verify the import modal actually opened. The click is occasionally swallowed by the app, so this is retried by its caller.
    Click Element    xpath=//button[contains(@class, 'home__import-btn')]
    Wait Until Element Is Visible    xpath=//input[@placeholder='Select a share code']    5s

Synchronize Activity
    [Documentation]    Click an activity/path card's sync button and wait for the upload to complete (the button gains the "uploaded" class once done). When ${activity_title} is given, first checks that card is visible on the home menu and scopes the sync button to it specifically - use this whenever more than one card could be on screen. Without it, falls back to assuming a single relevant sync button is visible (legacy behavior for existing callers).
    [Arguments]    ${activity_title}=${EMPTY}
    IF    '${activity_title}' != '${EMPTY}'
        Wait For Activity    ${activity_title}
        ${sync_button}=    Set Variable    xpath=//h3[contains(@class, 'activity-card') and text()='${activity_title}']/ancestor::div[3]//button[contains(@class, 'activity-card__action-button--sync')]
        ${uploaded_button}=    Set Variable    xpath=//h3[contains(@class, 'activity-card') and text()='${activity_title}']/ancestor::div[3]//button[contains(@class, 'activity-card__action-button--sync uploaded')]
    ELSE
        ${sync_button}=    Set Variable    xpath=//button[contains(@class, 'activity-card__action-button activity-card__action-button--sync')]
        ${uploaded_button}=    Set Variable    xpath=//button[contains(@class, 'activity-card__action-button activity-card__action-button--sync uploaded')]
    END
    Wait Until Element Is Visible    ${sync_button}    15s
    Click Element    ${sync_button}
    Sleep    5s
    Wait Until Element Is Visible    ${uploaded_button}    15s

Close Sync Status Modal
    [Documentation]    Close the Cloud Sync Status modal left open by "Synchronize Activity" / "Resync Activity". Not called automatically by either of those, since several callers (Generate Share Code and friends) keep interacting with the modal after sync completes - call this explicitly once you're done with it, e.g. before a keyword that needs the normal app header uncovered (the modal overlay otherwise intercepts clicks on it).
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'cloud-sync-status-modal__close')]    10s
    Click Element    xpath=//button[contains(@class, 'cloud-sync-status-modal__close')]
    Wait Until Element Is Not Visible    xpath=//button[contains(@class, 'cloud-sync-status-modal__close')]    5s

Get Share Code From Sync Modal
    [Documentation]    From an already-open Cloud Sync Status modal: click the given "generate" button locator, confirm the resulting irreversible-action warning dialog, then read and return the "<code>" element that appears. Shared tail of "Generate Share Code", "Generate Share Code With Id" and "Generate Template Share Code" - only the "generate" button itself differs between the "Read-only" tab (default) and the "Template" tab, everything after it is identical.
    [Arguments]    ${generate_button_locator}=xpath=//button[contains(@class, 'cloud-sync-status-modal__sharing-generate-button')]
    Wait Until Element Is Visible    ${generate_button_locator}    15s
    Click Element    ${generate_button_locator}
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'ant-btn-dangerous')]    15s
    Click Element    xpath=//button[contains(@class, 'ant-btn-dangerous')]
    Wait Until Element Is Visible    xpath=//code    30s
    ${code}=    Get Text    xpath=//code
    RETURN    ${code}

Generate Share Code
    [Documentation]    Synchronize an activity/path, open its sharing panel and return the read-only share code (shown on the default "Read-only" tab). Pass ${activity_title} to check the card exists and scope the sync to it specifically when more than one card could be on screen.
    [Arguments]    ${activity_title}=${EMPTY}
    Synchronize Activity    ${activity_title}
    ${code}=    Get Share Code From Sync Modal
    RETURN    ${code}

Generate Share Code With Id
    [Documentation]    Same as "Generate Share Code", but scopes the sync button to the card's "data-id" instead of its title. Use this whenever several look-alike cards (same title, duplicates, stale data from earlier runs) could be on screen.
    [Arguments]    ${card_id}
    ${sync_button}=    Set Variable    xpath=//div[contains(@class, 'activity-card') and @data-id='${card_id}']//button[contains(@class, 'activity-card__action-button--sync')]
    ${uploaded_button}=    Set Variable    xpath=//div[contains(@class, 'activity-card') and @data-id='${card_id}']//button[contains(@class, 'activity-card__action-button--sync uploaded')]
    Wait Until Element Is Visible    ${sync_button}    15s
    Scroll Element Into View    ${sync_button}
    Click Element    ${sync_button}
    Sleep    5s
    Wait Until Element Is Visible    ${uploaded_button}    15s
    ${code}=    Get Share Code From Sync Modal
    RETURN    ${code}

Generate Template Share Code
    [Documentation]    Synchronize an activity/path, open its sharing panel, switch to the "Template" tab and return the generated template share code. Unlike the read-only code (shown immediately), the Template tab requires clicking "Generate Template Code" and then confirming an irreversible-action warning dialog before a code appears - verified live, no "<code>" element exists there until both are clicked. Pass ${activity_title} to scope the sync to a specific card when more than one could be on screen.
    [Arguments]    ${activity_title}=${EMPTY}
    Synchronize Activity    ${activity_title}
    Wait Until Element Is Visible    xpath=//div[contains(@class,'ant-tabs-tab') and .//text()='Template']    15s
    Click Element    xpath=//div[contains(@class,'ant-tabs-tab') and .//text()='Template']
    ${code}=    Get Share Code From Sync Modal    xpath=//button[contains(., 'Generate Template Code')]
    RETURN    ${code}

Import Activity
    [Documentation]    Import an activity using the provided code. Read-only imported activities are tied to the browser session/machine, not the signed-in account (confirmed behavior, not a bug) - closing the browser deletes them. Never call "Close Browser" between importing and using an imported activity in the same test, or it will no longer be found afterwards.
    [Arguments]    ${code}
    Wait Until Element Is Not Visible    xpath=//*[contains(text(), 'Importing')]    30s
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__import-btn')]    15s
    Wait Until Keyword Succeeds    3x    3s    Open Import Modal
    Click Element    xpath=//input[@placeholder='Select a share code']
    Input Text    xpath=//input[@placeholder='Select a share code']    ${code}
    Click Element    xpath=//button[contains(@class, 'import-modal__button') and contains(@class, 'import-modal__button--primary')]

Open Activity Menu And Duplicate
    [Documentation]    Click an activity card's menu button and select "Duplicate". Retried by its caller since a freshly created or duplicated card can take a moment to become fully interactive. The "Duplicate" menu item is clicked via JavaScript, filtered to the one that is actually visible, because Ant Design leaves previous dropdown instances mounted (hidden) in the DOM, which makes a plain xpath match the wrong, invisible one once a second dropdown has been opened.
    [Arguments]    ${activity_title}
    ${card}=    Set Variable    xpath=//h3[contains(@class, 'activity-card') and text()='${activity_title}']/ancestor::div[3]
    Wait Until Element Is Visible    ${card}//button[contains(@class, 'activity-card__menu-button')]    15s
    Wait Until Element Is Not Visible    ${card}//*[contains(text(), 'Sync in progress')]    20s
    Scroll Element Into View    ${card}//button[contains(@class, 'activity-card__menu-button')]
    Click Element    ${card}//button[contains(@class, 'activity-card__menu-button')]
    Sleep    1s
    ${clicked}=    Execute Javascript    var items=[...document.querySelectorAll('.ant-dropdown-menu-title-content')].filter(function(el){return el.textContent.trim()==='Duplicate' && el.offsetParent!==null;}); if(items.length===0){return false;} items[0].click(); return true;
    Should Be True    ${clicked}    Could not find a visible "Duplicate" menu item

Duplicate Activity
    [Documentation]    Duplicate the activity identified by the provided title. Scoped to that specific card (3rd div ancestor of its title) so it does not duplicate the wrong activity when several are visible on screen.
    [Arguments]    ${activity_title}
    Wait Until Keyword Succeeds    3x    2s    Open Activity Menu And Duplicate    ${activity_title}
    Sleep    2s

Open Activity Menu And Edit
    [Documentation]    Click an activity card's menu button and select "Edit" to reopen it in the editor. Mirrors "Open Activity Menu And Duplicate" for the same reasons (a fresh/duplicated card can take a moment to become interactive, and the "Edit" menu item is clicked via JavaScript filtered to the one that is actually visible, since Ant Design leaves previous dropdown instances mounted/hidden in the DOM).
    [Arguments]    ${activity_title}
    Wait Until Element Is Visible    xpath=//h3[contains(@class, 'activity-card') and text()='${activity_title}']    30s
    ${card}=    Set Variable    xpath=//h3[contains(@class, 'activity-card') and text()='${activity_title}']/ancestor::div[3]
    Wait Until Element Is Visible    ${card}//button[contains(@class, 'activity-card__menu-button')]    30s
    Wait Until Element Is Not Visible    ${card}//*[contains(text(), 'Sync in progress')]    20s
    Scroll Element Into View    ${card}//button[contains(@class, 'activity-card__menu-button')]
    Click Element    ${card}//button[contains(@class, 'activity-card__menu-button')]
    Sleep    1s
    ${clicked}=    Execute Javascript    var items=[...document.querySelectorAll('.ant-dropdown-menu-title-content')].filter(function(el){return el.textContent.trim()==='Edit' && el.offsetParent!==null;}); if(items.length===0){return false;} items[0].click(); return true;
    Should Be True    ${clicked}    Could not find a visible "Edit" menu item

Find And Open Activity Menu And Edit
    [Documentation]    Reload the page and then attempt "Open Activity Menu And Edit". Used as the retried action in "Reopen Activity Editor" - a just-created/just-synced activity can take a while to show up in the activity list on a fresh sign-in, and simply re-querying the same already-loaded page (without reloading) never gives it a chance to catch up.
    [Arguments]    ${activity_title}
    Reload Page
    Wait Until Element Is Not Visible    xpath=//div[contains(@class, 'loading-blocker__overlay')]    30s
    Open Activity Menu And Edit    ${activity_title}

Reopen Activity Editor
    [Documentation]    Reopen an existing activity identified by its title (via its card menu's "Edit" action) and step through the metadata pages to reach the augmentation canvas, ready to add more content with keywords like "Add Text To Augmentation". Verified live: unlike the single combined page used during initial creation, the reopened editor paginates title/instructions/description across separate "Next" clicks before reaching the "#three-canvas" board - if the app changes that step count this is the first place to check. The retry window is generous (12x15s = up to 3 minutes) since a heavier upload (e.g. video) can take noticeably longer to finish processing server-side before its card shows up on a fresh reload than a small text/image overlay does - confirmed live on 061_offline_video_after_online_creation.robot, where 8x15s (2 minutes) was not always enough.
    [Arguments]    ${activity_title}
    Wait Until Keyword Succeeds    12x    15s    Find And Open Activity Menu And Edit    ${activity_title}
    Sleep    2s
    Next button
    Sleep    2s
    Next button
    Sleep    2s
    Wait Until Element Is Visible    xpath=//div[@id='three-canvas']    15s

Delete Activity Or Path
    [Documentation]    Delete the activity or path card identified by the provided title. Every activity/path card carries a unique "data-id" attribute, so this first captures that id from the card matching the title, then scopes the menu-open and delete-confirm steps to that exact "data-id" instead of the title. This keeps the deletion correct even when several look-alike cards (same title, duplicates, stale data from earlier runs) are visible on screen at once.
    [Arguments]    ${card_title}
    ${card_id}=    Get Element Attribute    xpath=//h3[contains(@class, 'activity-card') and text()='${card_title}']/ancestor::div[@data-id][1]    data-id
    ${card}=    Set Variable    xpath=//div[contains(@class, 'activity-card') and @data-id='${card_id}']
    Wait Until Element Is Visible    ${card}//button[contains(@class, 'activity-card__menu-button')]    15s
    Scroll Element Into View    ${card}//button[contains(@class, 'activity-card__menu-button')]
    Click Element    ${card}//button[contains(@class, 'activity-card__menu-button')]
    Sleep    1s
    ${clicked}=    Execute Javascript    var items=[...document.querySelectorAll('.ant-dropdown-menu-title-content')].filter(function(el){return el.textContent.trim()==='Delete' && el.offsetParent!==null;}); if(items.length===0){return false;} items[0].click(); return true;
    Should Be True    ${clicked}    Could not find a visible "Delete" menu item
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'confirmation-dialog__footer')]//button[text()='Delete']    15s
    Click Element    xpath=//div[contains(@class, 'confirmation-dialog__footer')]//button[text()='Delete']
    RETURN    ${card_id}

Restore Activity Or Path
    [Documentation]    Open the Trash and restore the card identified by its "data-id" (as returned by "Delete Activity Or Path"). Scoping the restore button by data-id keeps this correct even if the trash holds several look-alike deleted cards. Restore is clicked via JavaScript (same "Click Visible Delete Permanently Button" pattern used below) rather than "Wait Until Element Is Visible" + "Click Element" - confirmed live that a "no-cover" path card renders "activity-card__action-button--restore" TWICE: once inside the thumbnail hover-reveal overlay ("activity-card__actions", sitting at opacity:0 until a real mouse hover - its "display"/"visibility"/bounding-rect all read as normal, but ChromeDriver's own is_displayed() correctly reports it as not shown) and once in an always-visible "activity-card__top-actions" wrapper (per the app's "top-actions wrapper only exists for path cards, not activity cards" layout). A locator matching both grabs the first (opacity-hidden) one in DOM order and "Wait Until Element Is Visible" times out even though the second one is genuinely clickable - a JS-triggered ".click()" sidesteps the native visibility check entirely and fires the button's handler regardless of which duplicate it hits.
    [Arguments]    ${card_id}
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'ds-header__download-button') and @title='Trash']    15s
    Click Element    xpath=//button[contains(@class, 'ds-header__download-button') and @title='Trash']
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'activity-card') and @data-id='${card_id}']    15s
    Wait Until Keyword Succeeds    10x    1s    Click Visible Restore Button    ${card_id}

Click Visible Restore Button
    [Documentation]    Helper for "Restore Activity Or Path": find and JS-click the restore button for the given card id (see that keyword's docstring for why a plain visibility-scoped click is not reliable here).
    [Arguments]    ${card_id}
    ${clicked}=    Execute Javascript    var card=document.querySelector("div.activity-card[data-id='${card_id}']"); if(!card){return false;} var items=[...card.querySelectorAll("button.activity-card__action-button--restore")]; if(items.length===0){return false;} items[items.length-1].click(); return true;
    Should Be True    ${clicked}    Could not find a "Restore" button for card ${card_id}

Delete Activity Or Path Permanently
    [Documentation]    Open the Trash and permanently delete the card identified by its "data-id" (as returned by "Delete Activity Or Path"). Scoping the button by data-id keeps this correct even if the trash holds several look-alike deleted cards. Clicked via JS filtering by "offsetParent !== null" (same stale-node pattern used elsewhere in this file) - confirmed live (offline group) that "Click Element" here can hit "element click intercepted" against another element sharing the exact same class list, i.e. a stale mounted-but-hidden duplicate of this button rather than the currently visible one.
    [Arguments]    ${card_id}
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'ds-header__download-button') and @title='Trash']    15s
    Click Element    xpath=//button[contains(@class, 'ds-header__download-button') and @title='Trash']
    ${card}=    Set Variable    xpath=//div[contains(@class, 'activity-card') and @data-id='${card_id}']
    Wait Until Element Is Visible    ${card}//button[contains(@class, 'activity-card__action-button--delete') and @title='Delete permanently']    15s
    Wait Until Keyword Succeeds    10x    1s    Click Visible Delete Permanently Button    ${card_id}
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'confirmation-dialog__footer')]//button[text()='Delete']    15s
    Click Element    xpath=//div[contains(@class, 'confirmation-dialog__footer')]//button[text()='Delete']

Click Visible Delete Permanently Button
    [Documentation]    Helper for "Delete Activity Or Path Permanently": find and click the currently visible "Delete permanently" button for the given card id, ignoring any stale hidden duplicate.
    [Arguments]    ${card_id}
    ${clicked}=    Execute Javascript    var card=document.querySelector("div.activity-card[data-id='${card_id}']"); if(!card){return false;} var items=[...card.querySelectorAll("button.activity-card__action-button--delete[title='Delete permanently']")].filter(function(el){return el.offsetParent!==null;}); if(items.length===0){return false;} items[0].click(); return true;
    Should Be True    ${clicked}    Could not find a visible "Delete permanently" button for card ${card_id}

Create basic search and find activity
    [Documentation]    Create a basic search and find activity with a title, instructions, snap the background and validate
    [Arguments]    ${title}    ${instructions}
    Create Activity
    Select Activity Type    Search and Find
    Next button
    Sleep    2s
    Edit Activity Title    ${title}
    Edit Activity Instructions    ${instructions}
    Click Element    xpath=//button[contains(@class, 'ant-btn-primary') and contains(@class, 'editor__nav-button') and contains(@class, 'editor__nav-button--primary')]
    Sleep    2s
    Provide Marker Image    Search and Find
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    5s
    Next button
    Sleep    5s

Create failed search and find activity
    [Documentation]    Create a basic search and find activity with a title, instructions, use a photo and validate Safari: runs the same Selenium action chain (no JavaScript fallback) - UNVERIFIED there, since which events the app listens for (pointer/mouse vs HTML5 drag-and-drop) is not confirmed; callers are tagged "safari-unverified".
    [Arguments]    ${title}    ${instructions}
    Create Activity
    Select Activity Type    Search and Find
    Next button
    Sleep    2s
    Edit Activity Title    ${title}
    Edit Activity Instructions    ${instructions}
    Click Element    xpath=//button[contains(@class, 'ant-btn-primary') and contains(@class, 'editor__nav-button') and contains(@class, 'editor__nav-button--primary')]
    Sleep    2s
    Use template image
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    5s

    Wait Until Element Is Visible    xpath=//div[contains(@class, 'ant-slider-handle')]    15s
    Drag And Drop    xpath=//div[contains(@class, 'ant-slider-handle')]    xpath=//div[contains(@id, 'three-canvas')]

    Next button
    Sleep    5s

Create basic pairs activity
    [Documentation]    Create a basic pairs activity with a title, instructions, snap the background and validate. Verified live: unlike the marker-compiled activity types (Augmented, Search and Find, Superposition), Pair Association's two images are plain direct uploads with no marker-compilation step - there is no "marker-features" modal here, so the step after both uploads is just the regular editor nav "Next" button ("Next button" keyword), not "Validation button" (which is scoped to that modal and would never appear). Using "Validation button" here previously happened to still work only because its old unscoped "button[text()='Next']" match coincidentally hit the right element - it broke once a driver.js onboarding tour (triggered the first time a fresh account creates a Pair Association activity - see pairAssociationTour.ts) started rendering its own "Next" button with the exact same text, which that bare text-match could no longer disambiguate from.
    [Arguments]    ${title}    ${instructions}
    Create Activity
    Select Activity Type    Pair Association
    Next button
    Sleep    2s
    Edit Activity Title    ${title}
    Edit Activity Instructions    ${instructions}
    Click Element    xpath=//button[contains(@class, 'ant-btn-primary') and contains(@class, 'editor__nav-button') and contains(@class, 'editor__nav-button--primary')]
    Sleep    2s
    Wait Until Element Is Visible    xpath=//span[contains(@class, ant-upload-btn)]    15s
    Click Element    xpath=//span[contains(@class, ant-upload-btn)]
    Choose File Robust    xpath=//input[@type='file']    ${EXECDIR}/assets/fakecamfeed_cortez.png
    Sleep    2s
    Click Element    xpath=//span[contains(@class, ant-upload-btn)]
    Choose File Robust    xpath=//input[@type='file']    ${EXECDIR}/assets/cat.webp
    Sleep    2s
    Next button
    Sleep    2s
    Next button
    Sleep    5s

Create basic layers activity
    [Documentation]    Create a basic layers activity with a title, instructions, snap the background
    [Arguments]    ${title}    ${instructions}
    Create Activity
    Select Activity Type    Information layers
    Next button
    Sleep    2s
    Edit Activity Title    ${title}
    Edit Activity Instructions    ${instructions}
    Click Element    xpath=//button[contains(@class, 'ant-btn-primary') and contains(@class, 'editor__nav-button') and contains(@class, 'editor__nav-button--primary')]
    Sleep    2s
    Provide Marker Image    Information layers
    Sleep    2s
    Next button
    Sleep    2s
    Validation button
    Sleep    5s
    Next button
    Sleep    5s

Create basic layers activity without validation
    [Documentation]    Create a basic layers activity with a title, instructions, snap the background
    [Arguments]    ${title}    ${instructions}
    Create Activity
    Select Activity Type    Information layers
    Next button
    Sleep    2s
    Edit Activity Title    ${title}
    Edit Activity Instructions    ${instructions}
    Click Element    xpath=//button[contains(@class, 'ant-btn-primary') and contains(@class, 'editor__nav-button') and contains(@class, 'editor__nav-button--primary')]
    Sleep    2s
    Provide Marker Image    Information layers
    Sleep    2s
    Next button
    Sleep    5s
    Validation button
    Sleep    5s

Add multiple layers
    [Documentation]    Add multiple layers to the current activity
    [Arguments]    ${number_of_layers}=3
    FOR    ${index}    IN RANGE    ${number_of_layers}
        Click Element    xpath=//button[contains(@class, 'layers-panel__add-button')]
        Wait Until Element Is Visible    xpath=//button[contains(@class, 'layers-panel__edit-button--validate')]    15s
        Click Element    xpath=//button[contains(@class, 'layers-panel__edit-button--validate')]
        Sleep    2s
    END

Furnish layers with content
    [Documentation]    Furnish each layer with content (cat image)
    [Arguments]    ${number_of_layers}=3
    FOR    ${index}    IN RANGE    ${number_of_layers}
        Click Element    xpath=//div[contains(@class, 'layers-panel__tile-name') and text()='Layer ${index + 1}']
        Click Element    xpath=//button[contains(@title, 'Image')]
        Sleep    2s
        Click Element    xpath=//h5[contains(@class, 'ant-typography') and text()='Click to edit...']
        Click Element    xpath=//button[contains(@class, 'ant-btn')]
        Choose File Robust    xpath=//input[@type='file']    ${EXECDIR}/assets/cat.webp
        Wait Until Element Is Visible    xpath=//button[contains(@title, 'Expand Layers')]    15s
        Click Element    xpath=//button[contains(@title, 'Expand Layers')] 
        Sleep    2s
    END

Check if Layer has content
    [Documentation]    Check if a specific layer has content (cat image)
    [Arguments]    ${layer_index}
    Click Element    xpath=//div[contains(@class, 'layers-panel__tile-name') and text()='Layer ${layer_index + 1}']
    ${rows}=    Get WebElements    xpath=//div[contains(@class, 'auras__html-container')]
    ${count}=   Get Length         ${rows}
    Should Be True    ${count} == 1
    Log    Nombre d'activités: ${count} (devrait être 1)

Check that all layers are present and contain the expected content
    [Documentation]    Check that all layers are present and contain the expected content (cat image)
    [Arguments]    ${number_of_layers}=3
    FOR    ${index}    IN RANGE    ${number_of_layers}
        Check if Layer has content    ${index}
    END

Change Language
    [Documentation]    Change the language of the application using the provided language name.
    ### FR = Français
    ### EN = English
    ### DK = Dansk
    ### GR = Ελληνικά
    ### TR = Türkçe
    [Arguments]    ${language_code}
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'ds-header__language-dropdown')]    5s
    Click Element    xpath=//div[contains(@class, 'ds-header__language-dropdown')]
    Wait Until Element Is Visible    xpath=//div[@role='option'][.//span[text()='${language_code}']]    5s
    Click Element    xpath=//div[@role='option'][.//span[text()='${language_code}']]

Check that the page is in French
    [Documentation]    Check that the page is in French by verifying the presence of a specific French text.
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn') and text()='Nouvelle activité']    2s
    Change Language    English
    Create empty augmented activity    title=Activité augmentée de test
    Change Language    Français
    Sleep    2s
    Wait Until Element Is Visible    xpath=//button[text()="Nouveau parcours d'apprentissage"]   2s
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'activity-card__status-badges')]//span[text()='Brouillon local']    2s

Check that the page is in English
    [Documentation]    Check that the page is in English by verifying the presence of a specific English text.
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn') and text()='New activity']    2s
    Create empty augmented activity    title=Test Augmented Activity
    Sleep    2s
    Wait Until Element Is Visible    xpath=//button[text()="New learning path"]   2s
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'activity-card__status-badges')]//span[text()='Local draft']    2s

Check that the page is in Danish
    [Documentation]    Check that the page is in Danish by verifying the presence of a specific Danish text.
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn') and text()='Ny aktivitet']    2s
    Change Language    English
    Create empty augmented activity    title=Test Forstærket Aktivitet
    Change Language    Dansk
    Sleep    2s
    Wait Until Element Is Visible    xpath=//button[text()="Ny læringssti"]   2s
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'activity-card__status-badges')]//span[text()='Lokal kladde']    2s

Check that the page is in Greek
    [Documentation]    Check that the page is in Greek by verifying the presence of a specific Greek text.
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn') and text()='Νέα δραστηριότητα']    2s
    Change Language    English
    Create empty augmented activity    title=Δοκιμή Επαυξημένης Δραστηριότητας
    Change Language    Ελληνικά
    Sleep    2s
    Wait Until Element Is Visible    xpath=//button[text()="Ένας νέος τρόπος μάθησης"]   2s
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'activity-card__status-badges')]//span[text()='Τοπικό προσχέδιο']    2s

Check that the page is in Turkish
    [Documentation]    Check that the page is in Turkish by verifying the presence of a specific Turkish text.
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__new-activity-btn') and text()='Yeni etkinlik']    2s
    Change Language    English
    Create empty augmented activity    title=Test Artırılmış Etkinlik
    Change Language    Türkçe
    Sleep    2s
    Wait Until Element Is Visible    xpath=//button[text()="Yeni öğrenme yolu"]   2s
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'activity-card__status-badges')]//span[text()='Yerel taslak']    2s

Play Activity
    [Documentation]    Opens the activity by title, launching its AR player view via its title-arrow-button. Scoped to that specific card so it does not launch the wrong activity when several look-alike cards are visible on screen.
    [Arguments]    ${activity_title}
    Wait For Activity    ${activity_title}
    ${play_button}=    Set Variable    xpath=//h3[contains(@class, 'activity-card') and text()='${activity_title}']/ancestor::div[3]//button[contains(@class, 'activity-card__title-arrow-button')]
    Wait Until Element Is Visible    ${play_button}    15s
    Click Element    ${play_button}

Play Path
    [Documentation]    Paths and activities share the same title-arrow-button launch control, so this just delegates to "Play Activity".
    [Arguments]    ${path_title}
    Play Activity    ${path_title}

Go To Next Activity In Path Player
    [Documentation]    Click the AR player's "next" control to advance to the next activity in a multi-activity path (e.g. a Guided Path). Verified live: this navigates immediately regardless of whether the current activity's target has actually been detected yet - it is not gated on detection, only disabled on the path's last activity. The player toolbar has 4 buttons in DOM order (home, previous, next, list-overview); this is the 2nd of the 2 non-circular ones.
    Click Element    xpath=(//button[contains(@class, 'auraplay__control-btn') and not(contains(@class, 'auraplay__control-btn--circle'))])[2]
    Sleep    2s

Go To Previous Activity In Path Player
    [Documentation]    Click the AR player's "previous" control to go back to the previous activity in a multi-activity path. Disabled (and so a no-op) on the path's first activity.
    Click Element    xpath=(//button[contains(@class, 'auraplay__control-btn') and not(contains(@class, 'auraplay__control-btn--circle'))])[1]
    Sleep    2s

Path Player Previous Button Should Be Disabled
    [Documentation]    Assert the AR player's "previous" control is disabled - true when the currently displayed activity is the first one in the path.
    Element Should Be Disabled    xpath=(//button[contains(@class, 'auraplay__control-btn') and not(contains(@class, 'auraplay__control-btn--circle'))])[1]

Path Player Previous Button Should Be Enabled
    [Documentation]    Assert the AR player's "previous" control is enabled - true whenever the currently displayed activity is not the first one in the path.
    Element Should Be Enabled    xpath=(//button[contains(@class, 'auraplay__control-btn') and not(contains(@class, 'auraplay__control-btn--circle'))])[1]

Exit Path Player
    [Documentation]    Click the AR player's "home" control to return to the home grid. Needed before calling any keyword that relies on the normal app header (e.g. "Sign Out", "Delete Account") - the player's own minimal header does not include the user avatar menu. Verified live via a full DOM dump of the top-right corner: the visible house icon is a "div.auraplay__home-btn" (role="button", 60x60) - NOT the small 22x22 "button.auraplay__home-btn-close" ("Dismiss"/close-X icon) that overlaps its corner, which is a separate notification-badge-dismiss control and does nothing to the player when clicked (an earlier version of this keyword targeted that wrong element and silently no-opped). Clicks via JS ("offsetParent !== null" filter) since it's a div with a synthetic role, not a native button, and Click Element's native click can be intercepted by the overlapping close-badge button.
    Wait Until Keyword Succeeds    10x    1s    Click Visible Path Player Home Button
    Wait Until Element Is Visible    xpath=//button[.//span[contains(@class, 'anticon anticon-user')]]    20s

Click Visible Path Player Home Button
    [Documentation]    Helper for "Exit Path Player": find and click the currently visible "auraplay__home-btn" control, ignoring any stale hidden copies left mounted from earlier player renders.
    ${clicked}=    Execute Javascript    var items=[...document.querySelectorAll('.auraplay__home-btn')].filter(function(el){return el.offsetParent!==null;}); if(items.length===0){return false;} items[0].click(); return true;
    Should Be True    ${clicked}    Could not find a visible "auraplay__home-btn" element

Resync Activity
    [Documentation]    Click an activity/path card's sync button after it has already been synced once, confirm the resync in the cloud sync status modal, and wait for the upload to complete again.
    [Arguments]    ${activity_title}=${EMPTY}
    IF    '${activity_title}' != '${EMPTY}'
        Wait For Activity    ${activity_title}
        ${sync_button}=    Set Variable    xpath=//h3[contains(@class, 'activity-card') and text()='${activity_title}']/ancestor::div[3]//button[contains(@class, 'activity-card__action-button--sync')]
        ${uploaded_button}=    Set Variable    xpath=//h3[contains(@class, 'activity-card') and text()='${activity_title}']/ancestor::div[3]//button[contains(@class, 'activity-card__action-button--sync uploaded')]
    ELSE
        ${sync_button}=    Set Variable    xpath=//button[contains(@class, 'activity-card__action-button activity-card__action-button--sync')]
        ${uploaded_button}=    Set Variable    xpath=//button[contains(@class, 'activity-card__action-button activity-card__action-button--sync uploaded')]
    END
    Wait Until Element Is Visible    ${sync_button}    15s
    Click Element    ${sync_button}
    Sleep    5s
    # Some activities resync immediately (the modal opens already showing "Synced" with no
    # confirmation needed), others show a confirm button in the cloud sync status modal first
    # (observed live in both states). Click it only if it actually appears, instead of assuming
    # either behavior.
    ${confirm_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//button[contains(@class, 'cloud-sync-status-modal__button cloud-sync-status-modal__button--primary')]    5s
    IF    ${confirm_visible}
        Click Element    xpath=//button[contains(@class, 'cloud-sync-status-modal__button cloud-sync-status-modal__button--primary')]
    END
    Wait Until Element Is Visible    ${uploaded_button}    15s

Filter by tag
    [Documentation]    Toggle the given tag on/off in the home menu's label filter (multiple tags can be selected at once - selecting more than one is a logical OR, showing any activity that carries at least one of the selected tags, not just activities carrying all of them). Verified live: like the Ant Design dropdown menus elsewhere in this app, this panel can leave a stale, hidden previous instance mounted after closing, so a plain xpath text match can hit that stale node instead of the current visible one once the panel has been opened more than once in the same test run - the chip click is filtered by offsetParent!==null to avoid that, same pattern as "Open Activity Menu And Duplicate" / "Delete Activity Or Path".
    [Arguments]    ${tag_name}
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__labels-btn')]    5s
    Click Element    xpath=//button[contains(@class, 'home__labels-btn')]
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'labels-panel')]    5s
    Wait Until Keyword Succeeds    5x    1s    Click Visible Tag Chip    ${tag_name}
    Click Element    xpath=//button[contains(@class, 'labels-panel__close')]
    Sleep    2s

Click Visible Tag Chip
    [Documentation]    Click the tag chip matching ${tag_name} in whichever labels panel is currently open, filtered to visible (offsetParent!==null) chips only so a stale hidden previous instance is never hit. Retried by "Filter by tag" since the chip can take a moment to render after the panel opens.
    [Arguments]    ${tag_name}
    ${clicked}=    Execute Javascript    var items=[...document.querySelectorAll('.labels-panel__chip.labels-panel__chip--clickable')].filter(function(el){return el.textContent.trim()==='${tag_name}' && el.offsetParent!==null;}); if(items.length===0){return false;} items[0].click(); return true;
    Should Be True    ${clicked}    Could not find a visible tag chip for '${tag_name}'

Get Activity Number
    [Documentation]    Returns the number of activity/path cards present in the HOME menu.
    ${activities}=    Get WebElements    xpath=//h3[contains(@class, 'activity-card')]
    ${count}=    Get Length    ${activities}
    RETURN    ${count}

Set Sort Order
    [Documentation]    Open the home menu's "Sort" control and select "Sort A-Z" or "Sort Z-A" (pass ${order}=az or ${order}=za). The app applies the change immediately - there's no confirm button - so this just picks the matching radio option, then closes the popover by clicking the header logo, since re-clicking the Sort button doesn't toggle it closed and Escape doesn't dismiss it either (confirmed by live inspection).
    [Arguments]    ${order}
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'home__filter-btn--sort')]    5s
    Click Element    xpath=//button[contains(@class, 'home__filter-btn--sort')]
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'home__sort-content')]    5s
    IF    "${order}" == "az"
        Click Element    xpath=//div[contains(@class, 'home__sort-content')]//label[.//span[text()='Sort A-Z']]
    ELSE
        Click Element    xpath=//div[contains(@class, 'home__sort-content')]//label[.//span[text()='Sort Z-A']]
    END
    Click Element    xpath=//div[contains(@class, 'ds-header__logo')]
    Wait Until Element Is Not Visible    xpath=//div[contains(@class, 'home__sort-content')]    5s

Activity Should Appear Before
    [Documentation]    Assert that the activity/path card titled ${first_title} appears before the one titled ${second_title} in the home grid's DOM order. Used to verify sort order via document order rather than on-screen position, since the app's own "Sort" popover explicitly warns that its masonry layout can visually reposition cards even though the underlying order is correct.
    [Arguments]    ${first_title}    ${second_title}
    ${is_before}=    Execute Javascript    var titles=[...document.querySelectorAll("h3.activity-card__title")].map(function(el){return el.textContent.trim();}); return titles.indexOf("${first_title}") < titles.indexOf("${second_title}");
    Should Be True    ${is_before}    '${first_title}' should appear before '${second_title}' in the grid

# --- Onboarding tour suppression (called automatically by every "Open Web Application*"
# keyword above) ---
# Every driver.js onboarding tour gates on a localStorage "seen/completed" flag (see
# storage.ts's ONBOARDING_KEYS) that "usePersistentState" (hooks/usePersistentState.ts) reads
# ONCE at mount, not reactively - so setting these flags only takes effect after a page
# reload, and must happen BEFORE Sign Up/Create Activity/etc., not after. Left unsuppressed,
# a fresh account's first visit to Home, or its first time picking a given activity type, can
# pop a tour popover over the exact UI the test is trying to interact with - confirmed live as
# the root cause of an "element click intercepted" failure in 037_pairs.robot (the tour's own
# "Next" button and the real app's "Next" button briefly coexist with identical text). Every
# other test file benefits from tours being fully suppressed by default; only the
# 0NN_onboarding_*.robot files call "Reset Onboarding Tour Flag" afterwards to selectively
# re-enable the one tour they're actually testing.

Suppress All Onboarding Tours
    [Documentation]    Seed every onboarding tour's "seen/completed" localStorage flag as true and reload, so no driver.js guided tour can trigger for the rest of this browser session. Called automatically by every "Open Web Application*" keyword - only onboarding tests should need to touch this directly (via "Reset Onboarding Tour Flag").
    Execute Javascript    ['mixap.onboarding.mainSeen','mixap.onboarding.teacherCompleted','mixap.onboarding.studentCompleted','mixap.onboarding.pairAssociationCompleted','mixap.onboarding.searchAndFindCompleted','mixap.onboarding.informationLayerCompleted','mixap.onboarding.autoTriggeredPathCompleted','mixap.onboarding.guidedPathCompleted'].forEach(function(k){localStorage.setItem(k, 'true');});
    Reload Page
    Wait Until Element Is Visible    xpath=//button[text()='New activity']    15s

Reset Onboarding Tour Flag
    [Documentation]    Clear one onboarding tour's "seen/completed" localStorage flag and reload, re-enabling just that tour to trigger again - every other tour stays suppressed (see "Suppress All Onboarding Tours", which every "Open Web Application*" keyword already called before this runs). ${tour_name} is one of: main, teacher, student, pairAssociation, searchAndFind, informationLayer, autoTriggeredPath, guidedPath (see storage.ts's ONBOARDING_KEYS). Call this right after "Open Web Application*" and before "Sign Up".
    [Arguments]    ${tour_name}
    ${flags}=    Create Dictionary
    ...    main=mixap.onboarding.mainSeen
    ...    teacher=mixap.onboarding.teacherCompleted
    ...    student=mixap.onboarding.studentCompleted
    ...    pairAssociation=mixap.onboarding.pairAssociationCompleted
    ...    searchAndFind=mixap.onboarding.searchAndFindCompleted
    ...    informationLayer=mixap.onboarding.informationLayerCompleted
    ...    autoTriggeredPath=mixap.onboarding.autoTriggeredPathCompleted
    ...    guidedPath=mixap.onboarding.guidedPathCompleted
    ${key}=    Get From Dictionary    ${flags}    ${tour_name}
    Execute Javascript    localStorage.removeItem('${key}');
    Reload Page
    Wait Until Element Is Visible    xpath=//button[text()='New activity']    15s

# --- Onboarding tours (driver.js-based guided walkthroughs, see src/features/onboarding/) ---
# Every tour is driven by the same underlying driver.js instance (driverInstance.ts), so the
# primitives below (popover wait/close/next, role picker, completion-flag check) are shared
# across all 8 tours (main/teacher/student/pairAssociation/searchAndFind/informationLayer/
# autoTriggeredPath/guidedPath). Each tour's own step content (verified live against
# src/features/onboarding/tours/*.ts) chains together EXISTING keywords in this file for its
# "actionStep"s - clicking the real highlighted element (e.g. "Next button", "Add Text To
# Augmentation") both performs the real action AND silently advances the tour (see
# driverInstance.ts's onHighlighted: it attaches its own click listener directly on that
# element, bypassing any e.stopPropagation() in the app's own handler) - so most tour steps
# need no dedicated tour-specific keyword at all, only "Click Onboarding Next Button" for the
# steps that have no single real action (info/freedom steps).

Wait For Onboarding Popover
    [Documentation]    Wait for a driver.js onboarding tour popover (title/description + Mixy) to be visible. Common entry point for asserting a tour has started or advanced to a new step. Verified live: on an "action" step, the popover can render slightly before driverInstance.ts's "onHighlighted" hook finishes attaching its click listener to the real target element - clicking that element immediately after this keyword returns can race ahead of the listener and perform the real action without ever notifying the tour, leaving it stuck showing the now-stale step. The short settle delay avoids that race.
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'driver-popover')]    15s
    Sleep    1s

Get Onboarding Popover Description
    [Documentation]    Return the current onboarding popover's description text.
    ${text}=    Get Text    xpath=//div[contains(@class, 'driver-popover-description')]
    RETURN    ${text}

Get Onboarding Popover Progress
    [Documentation]    Return the current onboarding popover's progress indicator text (e.g. "5 of 10" - rendered because every tour is created with "showProgress: true", see driverInstance.ts). Used to detect that the tour advanced to a new step without clicking "Next" - e.g. a "freedom" step with "advanceOnElementAppear" auto-advances once the real action's DOM signal appears. Prefer this over comparing description text: verified live that consecutive steps can share identical description copy (e.g. pairAssociationTour.ts's two marker-slot steps), which makes a text-equality check an unreliable false negative even when the tour genuinely advanced.
    ${text}=    Get Text    xpath=//span[contains(@class, 'driver-popover-progress-text')]
    RETURN    ${text}

Onboarding Popover Should Have Advanced From
    [Documentation]    Wait until the onboarding popover's progress indicator (see "Get Onboarding Popover Progress") differs from ${previous_progress} - confirms the tour moved to a new step (e.g. via "advanceOnElementAppear" after performing the real action a freedom step asks for), without clicking "Next" manually. Retries briefly since the MutationObserver-based auto-advance (driverInstance.ts) isn't instantaneous.
    [Arguments]    ${previous_progress}
    Wait Until Keyword Succeeds    15x    1s    Onboarding Popover Progress Should Not Be    ${previous_progress}

Onboarding Popover Should Have Advanced From Or Click Next
    [Documentation]    Same intent as "Onboarding Popover Should Have Advanced From" (confirm the tour moved past ${previous_progress}), but falls back to clicking the popover's own Next button if auto-advance doesn't happen within a shorter window. Verified live: "advanceOnElementAppear" can be reliable for one freedom step and inconsistent for the very next one in the same tour (e.g. pairAssociationTour.ts's two consecutive marker-slot steps) - since freedom steps always keep their own Next button available as "a manual fallback" (see pairAssociationTour.ts's own comment), this uses it rather than blocking on a MutationObserver signal that may not be firing for reasons outside this suite's control.
    [Arguments]    ${previous_progress}
    ${advanced}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    5x    1s    Onboarding Popover Progress Should Not Be    ${previous_progress}
    IF    not ${advanced}
        Click Onboarding Next Button
    END

Onboarding Popover Progress Should Not Be
    [Documentation]    Helper for "Onboarding Popover Should Have Advanced From".
    [Arguments]    ${previous_progress}
    ${current}=    Get Onboarding Popover Progress
    Should Not Be Equal    ${current}    ${previous_progress}

Onboarding Tour Should Not Be Active
    [Documentation]    Assert no onboarding tour popover is currently showing - true once a tour is completed, closed early via its "X" button, or never started.
    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class, 'driver-popover')]    10s

Click Onboarding Next Button
    [Documentation]    Click the onboarding popover's own "Next" button, or "Done" on a tour's final step (driver.js renders one or the other, never both - see the shared styling for "driver-popover-next-btn"/"driver-popover-done-btn" in Onboarding.scss). Only valid on info/freedom steps: action steps hide this button entirely (see each tour file's "HIDE_NEXT_BUTTONS" / "actionStep" - the real highlighted element is what advances those instead).
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'driver-popover-next-btn') or contains(@class, 'driver-popover-done-btn')]    15s
    Click Element    xpath=//button[contains(@class, 'driver-popover-next-btn') or contains(@class, 'driver-popover-done-btn')]

Click Onboarding Previous Button
    [Documentation]    Click the onboarding popover's own "Previous" button, returning to the prior step.
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'driver-popover-prev-btn')]    15s
    Click Element    xpath=//button[contains(@class, 'driver-popover-prev-btn')]

Click Onboarding Close Button
    [Documentation]    Click the onboarding popover's "X" close button, ending the tour early without stepping through the rest of it. Still marks the tour as completed (see OnboardingProvider.tsx's "goTo()": the driver's "onDestroyed" callback fires on any destroy, not only on natural completion) - use "Onboarding Tour Should Be Marked Completed" to confirm that, not as a proxy for "the user actually saw every step".
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'driver-popover-close-btn')]    15s
    Click Element    xpath=//button[contains(@class, 'driver-popover-close-btn')]

Close Onboarding Tour If Still Active
    [Documentation]    Fallback cleanup for a tour that should have already completed (e.g. a final action step's real click, like "Click home button", occasionally races ahead of driverInstance.ts's onHighlighted listener attachment and performs the real navigation without notifying the tour - the tour is then left showing a stale popover for a step whose real target no longer exists). If a popover is still showing, clicks its "X" close button (confirmed elsewhere in this file to reliably fire onDestroyed regardless of which step it's called from) rather than leaving the tour orphaned. No-op if the tour already correctly closed on its own - uses a short timeout so that common case doesn't pay a full wait.
    ${still_active}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//div[contains(@class, 'driver-popover')]    2s
    IF    ${still_active}
        Execute Javascript    var el=document.querySelector('.driver-popover-close-btn'); if(el){el.click();}
    END

Finish Onboarding Tour By Clicking Next
    [Documentation]    Repeatedly click the onboarding popover's "Next"/"Done" button until the tour closes. Use for a tail run of consecutive info/freedom steps where the exact remaining step count is uncertain - e.g. driver.js's "skipMissingElement: true" (driverInstance.ts) silently skips a step whose target element isn't present for the current activity type, so a hardcoded click count can undercount or overcount depending on which branch actually rendered. Clicks via JS rather than "Click Onboarding Next Button": verified live that a real app modal left open by an earlier step (e.g. the Cloud Sync Status modal, whose "qr-canvas" a later tour step still needs to target) can visually overlap a freedom-mode popover corner-pinned in the same screen region despite its higher z-index, which trips Selenium's own visibility check even though the element is genuinely clickable.
    FOR    ${i}    IN RANGE    20
        ${active}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//div[contains(@class, 'driver-popover')]    25s
        IF    not ${active}    BREAK
        Sleep    1s
        ${clicked}=    Execute Javascript    var el=document.querySelector('.driver-popover-next-btn, .driver-popover-done-btn'); if(!el){return false;} el.click(); return true;
        IF    not ${clicked}    BREAK
    END

Replay Onboarding Tour
    [Documentation]    Open the header's settings menu (gear icon, ".ds-header__menu-button") and click "Replay guided tour", manually re-launching the "main" tour regardless of its localStorage "seen" flag (see PageHeader.tsx's "onReplayTourClick" -> "replayTour('main')" in OnboardingProvider.tsx). Same Ant Design stale-hidden-dropdown-node JS-click pattern used elsewhere in this file (see "Delete Account" / "Open Activity Menu And Duplicate").
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'ds-header__menu-button')]    15s
    Click Element    xpath=//button[contains(@class, 'ds-header__menu-button')]
    Wait Until Element Is Visible    xpath=//span[contains(@class, 'ant-dropdown-menu-title-content') and contains(text(), 'Replay guided tour')]    5s
    ${clicked}=    Execute Javascript    var items=[...document.querySelectorAll('.ant-dropdown-menu-title-content')].filter(function(el){return el.textContent.trim()==='Replay guided tour' && el.offsetParent!==null;}); if(items.length===0){return false;} items[0].click(); return true;
    Should Be True    ${clicked}    Could not find a visible "Replay guided tour" menu item

Choose Onboarding Role
    [Documentation]    From the "main" tour's single step, click the custom "I'm a teacher" / "I'm a student" picker button (data-role="teacher"/"student" - see mainTour.ts's onPopoverRender), launching the corresponding tour. This step has no driver.js next/prev/close buttons at all ("showButtons: []" in mainTour.ts) - the role buttons are the only way to leave it.
    [Arguments]    ${role}
    Wait Until Element Is Visible    xpath=//button[contains(@class, 'onboarding-role-picker__btn') and @data-role='${role}']    15s
    Click Element    xpath=//button[contains(@class, 'onboarding-role-picker__btn') and @data-role='${role}']

Onboarding Tour Should Be Marked Completed
    [Documentation]    Assert the given tour's localStorage "seen/completed" flag is true (see storage.ts's ONBOARDING_KEYS map). ${tour_name} is the same key used across the onboarding feature: main, teacher, student, pairAssociation, searchAndFind, informationLayer, autoTriggeredPath, or guidedPath. Verified live: "usePersistentState" (hooks/usePersistentState.ts) persists to localStorage from a "useEffect" reacting to the state change, not synchronously inside the click handler - checking immediately after the tour closes can catch the write mid-flight, so this retries briefly instead of asserting once.
    [Arguments]    ${tour_name}
    ${flags}=    Create Dictionary
    ...    main=mixap.onboarding.mainSeen
    ...    teacher=mixap.onboarding.teacherCompleted
    ...    student=mixap.onboarding.studentCompleted
    ...    pairAssociation=mixap.onboarding.pairAssociationCompleted
    ...    searchAndFind=mixap.onboarding.searchAndFindCompleted
    ...    informationLayer=mixap.onboarding.informationLayerCompleted
    ...    autoTriggeredPath=mixap.onboarding.autoTriggeredPathCompleted
    ...    guidedPath=mixap.onboarding.guidedPathCompleted
    ${key}=    Get From Dictionary    ${flags}    ${tour_name}
    Wait Until Keyword Succeeds    20x    0.5s    Onboarding Flag Should Equal    ${key}    true

Onboarding Flag Should Equal
    [Documentation]    Helper for "Onboarding Tour Should Be Marked Completed" / "Onboarding Tour Should Not Be Marked Completed": read one localStorage key and assert its (JSON-stringified) value.
    [Arguments]    ${key}    ${expected}
    ${value}=    Execute Javascript    return localStorage.getItem('${key}');
    Should Be Equal As Strings    ${value}    ${expected}

Onboarding Tour Should Not Be Marked Completed
    [Documentation]    Assert the given tour's localStorage "seen/completed" flag is NOT set - used to confirm the precondition before a tour is expected to auto-trigger for the first time. See "Onboarding Tour Should Be Marked Completed" for the ${tour_name} values.
    [Arguments]    ${tour_name}
    ${flags}=    Create Dictionary
    ...    main=mixap.onboarding.mainSeen
    ...    teacher=mixap.onboarding.teacherCompleted
    ...    student=mixap.onboarding.studentCompleted
    ...    pairAssociation=mixap.onboarding.pairAssociationCompleted
    ...    searchAndFind=mixap.onboarding.searchAndFindCompleted
    ...    informationLayer=mixap.onboarding.informationLayerCompleted
    ...    autoTriggeredPath=mixap.onboarding.autoTriggeredPathCompleted
    ...    guidedPath=mixap.onboarding.guidedPathCompleted
    ${key}=    Get From Dictionary    ${flags}    ${tour_name}
    ${value}=    Execute Javascript    return localStorage.getItem('${key}');
    Should Not Be Equal As Strings    ${value}    true