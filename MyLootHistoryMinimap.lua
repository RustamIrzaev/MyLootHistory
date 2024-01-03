--[[
My Loot History - Rustam's loot history addon
Copyright (C) 2024  Rustam (https://github.com/RustamIrzaev)

This file is part of MyLootHistory

MyLootHistory (or My Loot History) is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

MyLootHistory is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MyLootHistory.  If not, see <http://www.gnu.org/licenses/>.
--]]

local MLH = MLH

local MLH_LDB = LibStub("LibDataBroker-1.1")
local MLH_MMIcon = LibStub("LibDBIcon-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MyLootHistory")
local MinimapIconName = "MyLootHistory_MinimapIcon_Object"

--https://www.wowhead.com/icons?filter=6;1;0
local minimapIcon = MLH_LDB:NewDataObject(MinimapIconName, {
    type = "data source",
    text = L["MM_IconTitle"],
    icon = "Interface\\Icons\\inv_misc_map09",
    OnClick = function(_, button)
        if (button == "LeftButton") then
            MLH:gui()
        elseif (button == "RightButton") then
            -- Settings.OpenToCategory("My Loot History")
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