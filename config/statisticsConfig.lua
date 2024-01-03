--[[
My Loot History addon
Copyright (C) 2024 Rustam (https://github.com/RustamIrzaev)

See License file for details.
--]]

local MLH = MLH
local L = LibStub("AceLocale-3.0"):GetLocale("MyLootHistory")

MLH.groupStatistics = {
    type = 'group',
    order = 32,
    name = L["C_Statistics"],
    args = {
        statisticsText = {
            type = 'description',
            fontSize = 'medium',
            name = '...',
        }
    }
}