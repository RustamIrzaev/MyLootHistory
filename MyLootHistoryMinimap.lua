--[[
My Loot History addon
Copyright (C) 2024 Rustam (https://github.com/RustamIrzaev)

See License file for details.
--]]

local MLH = MLH

local MLH_LDB = LibStub("LibDataBroker-1.1")
local MLH_MMIcon = LibStub("LibDBIcon-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MyLootHistory")
local MinimapIconName = "MyLootHistory_MinimapIcon_Object"

local minimapIcon = MLH_LDB:NewDataObject(MinimapIconName, {
    type = "data source",
    text = L["MM_IconTitle"],
    icon = "Interface\\Icons\\inv_misc_map09",
    OnClick = function(_, button)
        if (button == "LeftButton") then
            MLH:gui()
        elseif (button == "RightButton") then
            LibStub("AceConfigDialog-3.0"):Open("MyLootHistory_GeneralOptions")
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(L["MM_Title"])
        tooltip:AddLine(L["MM_Separator"])
        tooltip:AddLine(L["MM_LeftClickForReport"])
        tooltip:AddLine(L["MM_RightClickForSettings"])
    end,
})

function MLH:initMinimap()
    MLH_MMIcon:Register(MinimapIconName, minimapIcon, self.db.char.minimapData)

    if (self.db.char.minimapData.hide) then
        MLH_MMIcon:Hide(MinimapIconName)
    else
        MLH_MMIcon:Show(MinimapIconName)
    end
end