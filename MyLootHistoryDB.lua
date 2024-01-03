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
local ADB = LibStub("AceDB-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MyLootHistory")

local defaults = {
    char = {
        foundItems = {},
        foundGold = {},
        thisSessionStart = time(),

        minimapData = {
            hide = false,
        },

        config = {
            showLastLooted = false,
            -- showLastLootedTime = false,
            showItemID = false,
            showTooltip = true,
            showAdditionalTooltipData = false,
            reportIconSize = 24,
            ignoreQuestItems = true,
            ignoreItemsWithZeroPrice = true,
            resizableReportWindow = false,
            debug = {
                printLootedSummary = false,
                printOtherDebugInfo = false,
            },
        },

        params = {
            selectedRangeValue = 2,
            selectedQualityValue = 0,
            selectedExactItemQuality = false,
        },

        dbVersion = 1,
    },
}

function MLH:initDatabase()
    self.db = ADB:New("MyLootHistoryDB", defaults)
end

function MLH:addGold(quantity, zoneID)
    table.insert(self.db.char.foundGold, {
        quantity = quantity,
        foundOn = time(),
        zoneID = zoneID
    })
end

function MLH:addItem(itemID, quantity, itemLink, itemTexture, itemQuality, itemName, zoneID, sellPrice)
    local foundItems = self.db.char.foundItems
    local itemIndex = -1
    local totalQuantity = 0

    for i = 1, #foundItems do
        if (foundItems[i].itemId == itemID) then
            itemIndex = i
            break
        end
    end

    local newLootDataObj = {
        quantity = quantity,
        foundOn = time(),
        zoneID = zoneID,
        sellPrice = sellPrice or 0,
    }

    if (itemIndex == -1) then
        local newItem = {
            itemId = itemID,
            itemLink = itemLink,
            itemName = itemName,
            itemTexture = itemTexture,
            quality = itemQuality,
            lootData = {},
        }

        table.insert(newItem.lootData, newLootDataObj)
        table.insert(foundItems, newItem)
    else
        table.insert(foundItems[itemIndex].lootData, newLootDataObj)
    end

    if (itemIndex ~= -1) then
        for i = 1, #foundItems[itemIndex].lootData do
            totalQuantity = totalQuantity + foundItems[itemIndex].lootData[i].quantity
        end
    else
        totalQuantity = quantity
    end

    return totalQuantity
end

function MLH:resetData()
    self.db.char.foundItems = {}
    self.db.char.foundGold = {}
    MLH:updateStatisticsTextData()

    if (self.db.char.config.debug.printOtherDebugInfo) then
        print(L["M_DataWasCleared"])
    end
end