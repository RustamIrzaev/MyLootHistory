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
local L = LibStub("AceLocale-3.0"):GetLocale("MyLootHistory")

MLH.groupStatistics = {
    type = 'group',
    order = 32,
    name = 'Statistics',
    args = {
        statisticsText = {
            type = 'description',
            fontSize = 'medium',
            name = 'Statistics',
        }
    }
}