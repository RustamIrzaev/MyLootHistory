--[[
My Loot History addon
Copyright (C) 2024 Rustam (https://github.com/RustamIrzaev)

See License file for details.
--]]

local L = LibStub("AceLocale-3.0"):NewLocale("MyLootHistory", "enUS", true, true)

-- core
L["_MoneyPattern"] = "%d+"

L["_IntroMessage"] = function (addonName)
  return '|cFF00DD00'..addonName..'|r loaded. Happy looting! |cFFFF0000♥|r'
end

-- debug
L["D_AddedAndTotal"] = function (itemLink, totalAmount)
  return 'Added '..itemLink..'. Total quantity: '..totalAmount
end

L["D_NotMyItem"] = "not my item"
L["D_QuestItem"] = "quest item"
L["D_ZeroSellPrice"] = "sell price is 0"

-- minimap
L["MM_IconTitle"] = "My Loot History"
L["MM_Title"] = "|cFFFFFFFFMy Loot History|r"
L["MM_Separator"] = "|cFFAAAAAA---|r"
L["MM_LeftClickForReport"] = "|cFF00FF00Left click|r to open the report"
L["MM_RightClickForSettings"] = "|cFF00FF00Right click|r to open settings"

-- configuration
L["C_ShowMinimapButton"] = "Show minimap button"

-- messages
L["M_DataWasCleared"] = "Loot data and gold have been erased"