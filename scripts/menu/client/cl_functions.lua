-- =============================================
--  This file contains any strictly *pure* functions
--  that are utilized by the rest of the menu.
-- =============================================

--- Send a persistent alert to NUI
---@param key string An unique ID for this alert
---@param level string The level for the alert
---@param message string The message for this alert
---@param isTranslationKey boolean Whether the message is a translation key
function sendPersistentAlert(key, level, message, isTranslationKey)
    debugPrint(('Sending persistent alert, key: %s, level: %s, message: %s'):format(key, level, message))
    sendMenuMessage('setPersistentAlert', { key = key, level = level, message = message, isTranslationKey = isTranslationKey })
end

--- Clear a persistent alert on screen
---@param key string The unique ID passed in sendPersistentAlert for the notification
function clearPersistentAlert(key)
    debugPrint(('Clearing persistent alert, key: %s'):format(key))
    sendMenuMessage('clearPersistentAlert', { key = key })
end

--- Snackbar message
---@param level string The severity of the message can be 'info', 'error', or 'warning'
---@param message string Message to display with snackbar
function sendSnackbarMessage(level, message, isTranslationKey)
    debugPrint(('Sending snackbar message, level: %s, message: %s, isTranslationKey: %s'):format(level, message, isTranslationKey))
    sendMenuMessage('setSnackbarAlert', { level = level, message = message, isTranslationKey = isTranslationKey })
end

--- Send data to the NUI frame
---@param action string Action
---@param data any Data corresponding to action
function sendMenuMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

--- Toggle visibility of the txAdmin NUI menu
function toggleMenuVisibility(visible)
    debugPrint(isMenuVisible)
    if (visible == true and isMenuVisible) or (visible == false and not isMenuVisible) then
        return
    end
    if visible == nil then
        if not isMenuVisible and IsPauseMenuActive() then
            return
        end
    end
    -- Lets update before we open the menu
    updateServerCtx()
    sendMenuMessage('setDebugMode', isMenuDebug)
    if visible ~= nil then
        isMenuVisible = visible
        sendMenuMessage('setVisible', visible)
    else
        isMenuVisible = not isMenuVisible
        sendMenuMessage('setVisible', isMenuVisible)
    end
    PlaySoundFrontend(-1, SoundEnum['enter'], 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
end

--- Calculate a safe Z coordinate based off the (X, Y)
---@param x number
---@param y number
---@return number|nil
function FindZForCoords(x, y)
    local found = true
    local START_Z = 1500
    local z = START_Z
    while found and z > 0 do
        local _found, _z = GetGroundZFor_3dCoord(x + 0.0, y + 0.0, z - 1.0)
        if _found then
            z = _z + 0.0
        end
        found = _found
        Wait(0)
    end
    if z == START_Z then return nil end
    return z + 0.0
end

--- Display simple help scaleform
---@param msg string - The message to display
function DisplayHelpTxtThisFrame(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentString(msg)
    AddTextComponentSubstringTextLabel(msg)
    EndTextCommandDisplayHelp(0, 1, 0, -1);
end