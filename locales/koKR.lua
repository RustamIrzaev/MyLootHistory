--[[
My Loot History addon
Copyright (C) 2024 Rustam (https://github.com/RustamIrzaev)

See License file for details.
--]]

local L = LibStub("AceLocale-3.0"):NewLocale("MyLootHistory", "koKR")
if not L then return end

-- core
L["_MoneyPattern"] = "%d+"