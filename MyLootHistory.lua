--[[
My Loot History addon
Copyright (C) 2024 Rustam (https://github.com/RustamIrzaev)

See License file for details.
--]]

local addonName, addon = ...

MLH = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
-- local moneyPattern = GetLocale()=='ruRU' and '%d+ ' or '%d+'

function MLH:OnInitialize()
    self:initDatabase()
    self:initConfig()
    self:initMinimap()
    self:RegisterChatCommand("mlh", "SlashCommandListener")

    self.db.char.thisSessionStart = time()
    -- print('|cFF00DD00'..addonName..'|r loaded. Happy looting! |cFFFF0000♥|r')
    print(L["_IntroMessage"](addonName))
end

function MLH:OnEnable()
    self:RegisterEvent("CHAT_MSG_LOOT")
    self:RegisterEvent("CHAT_MSG_MONEY")
end

function MLH:Disable()
end

function MLH:CHAT_MSG_LOOT(_, message, ...)
    local message = message

    if (not self:isMyLoot(message)) then
        if (self.db.char.config.debug.printOtherDebugInfo) then
            print(L["D_NotMyItem"])
        end
        return
    end

    local itemLink, quantity, itemID, itemName, itemTexture, itemQuality, sellPrice = self:getLootDetails(message)

    if (self:isQuestItem(itemID)) then
        if (self.db.char.config.debug.printOtherDebugInfo) then
            print(L["D_QuestItem"])
        end
        return
    end

    if (sellPrice == 0 and self.db.char.config.ignoreItemsWithZeroPrice) then
        if (self.db.char.config.debug.printOtherDebugInfo) then
            print(L["D_ZeroSellPrice"])
        end
        return
    end

    local zoneID = self:getZoneID()
    -- ignore loot with zero price?

    -- local totalAmount = line below
    local totalAmount = self:addItem(itemID, quantity, itemLink, itemTexture, itemQuality, itemName, zoneID, sellPrice)

    if (self.db.char.config.debug.printLootedSummary) then
        -- print('Added '..itemLink..'. Total quantity: '..totalAmount)
        print(L["D_AddedAndTotal"](itemLink, totalAmount))
    end

    self:updateStatisticsTextData()
end

function MLH:CHAT_MSG_MONEY(_, message, ...)
    local message = message
    local moneyTable = {}
    _ = message:gsub(L["_MoneyPattern"], function(n) moneyTable[#moneyTable+1] = tonumber(n) end)
    local money = moneyTable[#moneyTable] + (moneyTable[#moneyTable-1] or 0)*100 + (moneyTable[#moneyTable-2] or 0)*10000

    self:addGold(money, self:getZoneID())
end

function MLH:isMyLoot(message)
    local lootString = LOOT_ITEM_SELF:gsub("%%s", ""):gsub("%.$", "")

    if (string.sub(message, 1, #lootString) == lootString) then
        return true
    end

    return false
end

function MLH:isQuestItem(itemID)
    -- probably, there might be something that is missing, will see
    -- for example itemID=76298 has cID=0 and scID=8 and it IS QUEST ITEM
    -- so see the second clause, hope it will work
    local classID = select(12, GetItemInfo(itemID))
    local subClassID = select(13, GetItemInfo(itemID))

    return (classID == Enum.ItemClass.Questitem) or (classID == Enum.ItemClass.Consumable and subClassID == 8)
end

function MLH:getLootDetails(message)
    local itemLink = string.match(message, "|c.-|h|r")
    local quantity = string.match(message, "x(%d+)%.*$") or 1
    local itemName = GetItemInfo(itemLink)
    local itemID = GetItemInfoFromHyperlink(itemLink)
    local itemTexture = select(10, GetItemInfo(itemID))
    local itemQuality = select(3, GetItemInfo(itemID))
    local sellPrice = select(11, GetItemInfo(itemID))
    
    return itemLink, quantity, itemID, itemName, itemTexture, itemQuality, sellPrice
end

function MLH:getZoneID()
    local zoneID = C_Map.GetBestMapForUnit("player")
    -- local zoneInfo = C_Map.GetMapInfo(zoneID)

    return zoneID
end

function MLH:SlashCommandListener(input)
    if (input == "config") then
        LibStub("AceConfigDialog-3.0"):Open("MyLootHistory_GeneralOptions")
    elseif (input == "gui") then
        self:gui()
    else
        self:gui()
    end
end