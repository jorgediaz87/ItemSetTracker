-- Initialize the addon
ItemSetTracker = {}
ItemSetTracker.name = "ItemSetTracker"

-- Default saved variables
ItemSetTracker.defaults = {
    trackedItems = {}
}

local ICON_ID = FCOIS_CON_ICON_STAR -- Example icon ID from FCOIS

-- Function to mark item sets as tracked
local function TrackItemSet(itemSetId)
    ItemSetTracker.savedVariables.trackedItems[itemSetId] = true
    d("Tracking item set: " .. itemSetId)
    -- Example: Use FCOIS to mark the set with a custom icon
    FCOIS.MarkItemByItemInstanceId(itemSetId, ICON_ID, true, true)
end

-- Function to unmark item sets as tracked
local function UntrackItemSet(itemSetId)
    ItemSetTracker.savedVariables.trackedItems[itemSetId] = nil
    d("Untracking item set: " .. itemSetId)
    -- Example: Use FCOIS to unmark the set with a custom icon
    FCOIS.MarkItemByItemInstanceId(itemSetId, ICON_ID, false, true)
end

-- Function to add context menu options
local function AddContextMenuOptions(control)
    ClearMenu()
    
    local itemSetId = control.itemSetId -- Assuming itemSetId is available

    if ItemSetTracker.savedVariables.trackedItems[itemSetId] then
        AddCustomMenuItem("Untrack Item Set", function()
            UntrackItemSet(itemSetId)
        end, MENU_ADD_OPTION_LABEL)
    else
        AddCustomMenuItem("Track Item Set", function()
            TrackItemSet(itemSetId)
        end, MENU_ADD_OPTION_LABEL)
    end

    ShowMenu(control)
end

-- Hook into the Item Set Browser's context menu
local function HookItemSetBrowser()
    local originalFunction = ZO_ItemSetBrowserEntry_OnMouseUp
    ZO_ItemSetBrowserEntry_OnMouseUp = function(control, button)
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            AddContextMenuOptions(control)
        end
        originalFunction(control, button)
    end
end

-- Initialize the addon when all addons are loaded
local function OnAddonLoaded(event, addonName)
    if addonName == ItemSetTracker.name then
        ItemSetTracker.savedVariables = ZO_SavedVars:New("ItemSetTrackerSavedVariables", 1, nil, ItemSetTracker.defaults)
        HookItemSetBrowser()
        EVENT_MANAGER:UnregisterForEvent(ItemSetTracker.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(ItemSetTracker.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
