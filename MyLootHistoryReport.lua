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
local AGUI = LibStub("AceGUI-3.0")
local DU = LibStub("DateUtils-1.0")

local isWindowShown = false
local baseWindowWidth = 640
local window = nil

-- add to appropriate functions
local rowWidth = {
    icon = 50,
    itemDetails = 250,
    quantity = 100,
    lastLooted = 200,
}

local rangeValue = 2
local qualityValue = 0
local exactItemQuality = false

local FrameBackdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
}

function MLH:gui()
    if (isWindowShown) then return end

    rangeValue = MLH.db.char.params.selectedRangeValue or 2
    qualityValue = MLH.db.char.params.selectedQualityValue or 0
    exactItemQuality = MLH.db.char.params.selectedExactItemQuality or false

    window = AGUI:Create("Frame")
    window:Hide()

    window:SetTitle("My Loot History")
    window:SetCallback("OnClose", function(widget)
        isWindowShown = false
        AGUI:Release(widget)
    end)
    window.frame:SetBackdrop(FrameBackdrop)
    window:SetLayout("Flow")
    window:SetWidth(self.db.char.config.showLastLooted and 650 or baseWindowWidth)
    window:EnableResize(self.db.char.config.resizableReportWindow or false)
    window:SetHeight(400)

    if (not _G["MLHReportFrame"]) then
        _G["MLHReportFrame"] = window.frame
        tinsert(UISpecialFrames, "MLHReportFrame")
    end

    local groupOptions = AGUI:Create("SimpleGroup")
    groupOptions:SetFullWidth(true)
    groupOptions:SetLayout("Flow")
    window:AddChild(groupOptions)

    local groupItems = AGUI:Create("SimpleGroup")
    groupItems:SetFullWidth(true)
    groupItems:SetFullHeight(true)
    groupItems:SetLayout("Fill")
    window:AddChild(groupItems)

    local timeRangeDropdown = AGUI:Create("Dropdown")
    timeRangeDropdown:SetLabel("Report date range")
    timeRangeDropdown:SetList(getRangeList())
    timeRangeDropdown:SetValue(rangeValue)
    timeRangeDropdown:SetCallback("OnValueChanged", function(widget, event, key)
        rangeValue = key
        MLH.db.char.params.selectedRangeValue = rangeValue
        addItems(groupItems)
    end)
    groupOptions:AddChild(timeRangeDropdown)

    local qualityDropdown = AGUI:Create("Dropdown")
    qualityDropdown:SetLabel("Minimum Item quality")
    qualityDropdown:SetList(getQualityList())
    qualityDropdown:SetValue(qualityValue)
    -- qualityDropdown:SetCallback("OnValueChanged", qualityValueChanged)
    qualityDropdown:SetCallback("OnValueChanged", function(widget, event, key)
        qualityValue = key
        MLH.db.char.params.selectedQualityValue = qualityValue
        addItems(groupItems)
    end)
    groupOptions:AddChild(qualityDropdown)

    local exactItemQualityCheckBox = AGUI:Create("CheckBox")
    exactItemQualityCheckBox:SetLabel("Exact item quality")
    exactItemQualityCheckBox:SetValue(exactItemQuality)
    exactItemQualityCheckBox:SetCallback("OnValueChanged", function(widget, event, value)
        exactItemQuality = not exactItemQuality
        MLH.db.char.params.selectedExactItemQuality = exactItemQuality
        addItems(groupItems)
    end)
    groupOptions:AddChild(exactItemQualityCheckBox)

    addItems(groupItems)

    window:Show()
    window:DoLayout()
    -- window:ApplyStatus()
    
    isWindowShown = true
end

-- function table.copy(t)
--     local u = { }
--     for k, v in pairs(t) do u[k] = v end
--     return setmetatable(u, getmetatable(t))
-- end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy

    if orig_type == 'table' then
        copy = {}

        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end

        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function getDate(addDays, reset)
    local curDate = date('*t')
    curDate.day = curDate.day + addDays
    curDate.isdst = nil

    if (reset) then
        curDate.hour = 0
        curDate.min = 0
        curDate.sec = 0
    end

    local newDate = date("*t", time(curDate))

    return newDate
end

-- refactor this along with addItems()
function calculateGoldFound()
    local gold = MLH.db.char.foundGold
    local totalGold = 0
    local incGold = function(item) totalGold = totalGold + item.quantity end

    for i = 1, #gold do
        local item = gold[i]

        if (rangeValue == 1) then --this session
            if (MLH.db.char.thisSessionStart) then
                if (item.foundOn >= MLH.db.char.thisSessionStart) then
                    incGold(item)
                end
            end
        elseif (rangeValue == 2) then --today
            if (DU:dateIsToday(item.foundOn)) then
                incGold(item)
            end
        elseif (rangeValue == 3) then --yesterday
            if (DU:dateIsYesterday(item.foundOn, true)) then
                incGold(item)
            end
        elseif (rangeValue == 4) then --this reset
            local wday = DU:getToday().wday

            if (DU:isWed(wday)) then
                if (DU:dateIsToday(item.foundOn)) then
                    incGold(item)
                end
            else
                local lastWedDate = DU:getLastWed(wday)

                if (DU:dateInRangeTillToday(item.foundOn, lastWedDate)) then
                    incGold(item)
                end
            end
        elseif (rangeValue == 5) then --this month
            if (DU:dateIsInCurrentMonth(item.foundOn)) then
                incGold(item)
            end
        elseif (rangeValue == 6) then --all the time
            incGold(item)
        end
    end

    return totalGold
end

-- add ignored items
function addItems(window)
    window:ReleaseChildren()

    local itemsFound = deepcopy(MLH.db.char.foundItems)
    local items = {}

    for i = 1, #itemsFound do
        local canBeAdded = false
        local item = itemsFound[i]
        local newItem = deepcopy(item)
        local addItem = function(ita) table.insert(newItem.lootData, ita) end

        newItem.lootData = {}
        newItem.totalQuantity = 0
        newItem.dateRange = ""

        for j = 1, #item.lootData do
            local lootData = item.lootData[j]

            if (rangeValue == 1) then --this session
                if (MLH.db.char.thisSessionStart) then
                    if (lootData.foundOn >= MLH.db.char.thisSessionStart) then
                        addItem(lootData)
                    end
                end
            elseif (rangeValue == 2) then --today
                if (DU:dateIsToday(lootData.foundOn)) then
                    addItem(lootData)
                end
            elseif (rangeValue == 3) then --yesterday
                if (DU:dateIsYesterday(lootData.foundOn, true)) then
                    addItem(lootData)
                end
            elseif (rangeValue == 4) then --this reset
                local wday = DU:getToday().wday

                if (DU:isWed(wday)) then
                    if (DU:dateIsToday(lootData.foundOn)) then
                        addItem(lootData)
                    end
                else
                    local lastWedDate = DU:getLastWed(wday)

                    if (DU:dateInRangeTillToday(lootData.foundOn, lastWedDate)) then
                        addItem(lootData)
                    end
                end
            elseif (rangeValue == 5) then --this month
                if (DU:dateIsInCurrentMonth(lootData.foundOn)) then
                    addItem(lootData)
                end
            elseif (rangeValue == 6) then --all the time
                addItem(lootData)
            end
        end

        if (#newItem.lootData > 0) then
            if (not exactItemQuality and newItem.quality >= qualityValue) then
                canBeAdded = true
            elseif (exactItemQuality and newItem.quality == qualityValue) then
                canBeAdded = true
            else
                canBeAdded = false
            end
        end

        newItem.totalQuantity = #newItem.lootData

        if (canBeAdded) then
            table.sort(newItem.lootData, function(l, r) return l.foundOn < r.foundOn end) -- desc
            
            --refactor this later
            local firstFind = newItem.lootData[1].foundOn
            local lastFind = newItem.lootData[#newItem.lootData].foundOn
            local firstFindDate = date('*t', firstFind)
            local lastFindDate = date('*t', lastFind)

            if (firstFindDate.yday ~= lastFindDate.yday) then
                local dateFormat = "%d %b"
                local addYearToFirstFind = firstFindDate.year ~= lastFindDate.year
                local firstFindFormat = dateFormat..(addYearToFirstFind and ' %Y' or '')
                local lastFindFormat = dateFormat..' %Y'

                newItem.dateRange = date(firstFindFormat, firstFind)..' - '..date(lastFindFormat, lastFind)
            else
                local dateFormat = "%d %b %Y, %a"

                if (MLH.db.char.config.showLastLootedTime) then
                    dateFormat = dateFormat.." %X"
                end

                newItem.dateRange = date(dateFormat, firstFind)
            end

            table.insert(items, newItem)
        end
    end

    local totalQuantity = 0
    local totalSellPrice = 0

    if (items == nil or #items== 0) then
        addNothingIsHereLabel(window)
    else
        local container = AGUI:Create("SimpleGroup")
        container:SetFullWidth(true)
        container:SetFullHeight(true)
        container:SetLayout("Fill")
        window:AddChild(container)

        local sf = AGUI:Create("ScrollFrame")
        sf:SetLayout("Flow")
        container:AddChild(sf)

        for i = 1, #items do
            local item = items[i]
            local itemID = item.itemId

            local itemLink = select(2, GetItemInfo(itemID)) or item.itemLink
            local itemName = GetItemInfo(itemID) or item.itemName
            local itemTexture = select(10, GetItemInfo(itemID)) or item.itemTexture
            local itemQuantity = item.totalQuantity
            local itemFoundOn = item.dateRange
            local itemQuality = select(3, GetItemInfo(itemID)) or item.quality
            local sellPrice = select(11, GetItemInfo(itemID)) or item.sellPrice

            totalQuantity = totalQuantity + itemQuantity
            totalSellPrice = totalSellPrice + (sellPrice or 0) * itemQuantity

            local itemFrame = AGUI:Create("SimpleGroup")
            itemFrame:SetLayout("Flow")
            itemFrame:SetFullWidth(true)
            itemFrame:SetHeight(40)

            -- local header = strsplit(":", itemLink)
            -- local _, linkType = strsplit("H", header)
            -- print('linkType='..linkType)

            addIconRow(itemFrame, itemLink, itemTexture, itemQuantity)
            addItemDetailsRow(itemFrame, itemName, itemID, itemQuality)
            addQuantityRow(itemFrame, itemQuantity)

            if (MLH.db.char.config.showLastLooted) then
                addLastLootedRow(itemFrame, itemFoundOn)
            end

            sf:AddChild(itemFrame)
        end

        local goldRow = addGoldEarnedRow()
        sf:AddChild(goldRow)

        local empty = AGUI:Create("SimpleGroup")
        empty:SetHeight(6)
        sf:AddChild(empty)

        sf:FixScroll()
        sf:SetScroll(10000)
        -- sf:SetScroll(container.frame:GetHeight() * #items)
    end

    updateSummary(#items, totalQuantity, totalSellPrice)
end

function updateSummary(totalItems, totalQuantity, totalSellPrice)
    if (window == nil) then return end

    if (totalItems == 0) then
        window:SetStatusText('Loot something')
        return
        
    end

    -- local gold = floor(math.abs(totalSellPrice) / 10000)
	-- local silver = mod(floor(math.abs(totalSellPrice) / 100), 100)
	-- local copper = mod(floor(math.abs(totalSellPrice)), 100)

    -- print(gold..' '..silver..' '..copper)
    -- print(GetMoneyString(totalSellPrice))

    window:SetStatusText('Items: |cFF00CC00'..totalItems..'|r, Quantity: |cFF00CC00'
        ..totalQuantity..'|r, Sell price: '..GetMoneyString(totalSellPrice))
end

function addGoldEarnedRow()
    local goldFrame = AGUI:Create("SimpleGroup")
    goldFrame:SetLayout("Flow")
    goldFrame:SetFullWidth(true)
    goldFrame:SetHeight(40)

    local itemIcon = AGUI:Create("Icon")
    local iconSize = MLH.db.char.config.reportIconSize

    itemIcon:SetImageSize(iconSize, iconSize)
    itemIcon:SetImage(133784)
    itemIcon:SetHeight(iconSize + 2)
    itemIcon:SetWidth(iconSize + 4)

    goldFrame:AddChild(itemIcon)

    local nameLabel = AGUI:Create("Label")

    nameLabel:SetText("Gold earned: "..GetMoneyString(calculateGoldFound()))
    nameLabel:SetWidth(250)

    goldFrame:AddChild(nameLabel)

    return goldFrame
end

function addIconRow(frame, itemLink, itemTexture, totalQuantity)
    local itemIcon = AGUI:Create("Icon")
    local iconSize = MLH.db.char.config.reportIconSize

    itemIcon:SetImageSize(iconSize, iconSize)
    itemIcon:SetImage(itemTexture)

    if (MLH.db.char.config.showTooltip) then
        itemIcon:SetCallback("OnEnter", function(_)
            GameTooltip:SetOwner(itemIcon.frame, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(itemLink)

            if (MLH.db.char.config.showAdditionalTooltipData) then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("|cFFDDDDDDTotal quantity gathered:|r |cFF00BB00"..(totalQuantity or 0)..'|r', 1, 1, 1, true)
            end

            GameTooltip:Show()
        end)

        itemIcon:SetCallback("OnLeave", function(_)
            GameTooltip:Hide()
        end)
    end

    itemIcon:SetCallback("OnClick", function(_, _, button)
        if (button == "LeftButton" and (IsLeftShiftKeyDown() or IsRightShiftKeyDown())) then
            insertLinkToChat(itemLink)
        end
    end)

    itemIcon:SetHeight(iconSize + 2)
    itemIcon:SetWidth(iconSize + 4)

    frame:AddChild(itemIcon)
end

function addItemDetailsRow(frame, itemName, itemId, itemQuality)
    local nameLabel = AGUI:Create("Label")
    local _, _, _, hex = GetItemQualityColor(itemQuality)
    local itemText = '|c'..hex..itemName..'|r'
    -- local itemText = itemLink

    if (MLH.db.char.config.showItemID) then
        itemText = itemText..'\n  |cFFAAAAAAid: '..itemId..'|r'
    end

    nameLabel:SetText(itemText)
    nameLabel:SetWidth(250)

    frame:AddChild(nameLabel)
end

function addQuantityRow(frame, itemQuantity)
    local quantityLabel = AGUI:Create("Label")

    quantityLabel:SetText("Quantity: "..itemQuantity)
    quantityLabel:SetWidth(100)

    frame:AddChild(quantityLabel)
end

function addLastLootedRow(frame, itemFoundOn)
    local itemFoundOnLabel = AGUI:Create("Label")
    itemFoundOnLabel:SetText("Looted: "..itemFoundOn)
    itemFoundOnLabel:SetWidth(200)

    frame:AddChild(itemFoundOnLabel)
end

function addNothingIsHereLabel(frame)
    local emptyLabel = AGUI:Create("Label")

    emptyLabel:SetText("Nothing is here yet.\n  Loot something or change the filters :)")
    emptyLabel:SetWidth(100)

    --add 'reset filters' button ?

    frame:AddChild(emptyLabel)
end

-- function qualityValueChanged(widget, event, key)
--     print('quality key='..key)
-- end

function insertLinkToChat(itemLink)
    if (not itemLink) then return end

    ChatEdit_TryInsertChatLink(itemLink)
    
    -- local activeWindow = ChatEdit_GetActiveWindow()

    -- if (not activeWindow) then
    --     ChatEdit_ActivateChat(ChatFrame1EditBox)
    --     activeWindow = ChatFrame1EditBox
    -- end

    -- if (activeWindow) then
    --     ChatEdit_ActivateChat(activeWindow)
    --     activeWindow:Insert(itemLink)
    -- end
end

function getQualityList()
    local result = {}

    for i = 0, Enum.ItemQualityMeta.NumValues - 4 do -- ignores artifact, wow token and legacy items
        local _, _, _, hex = GetItemQualityColor(i)
        result[i] = '|c'..hex.._G["ITEM_QUALITY" .. i .. "_DESC"]..'|r'
     end

     return result
end

function getRangeList()
    return {
        [1] = "This session",
        [2] = "Today",
        [3] = "Yesterday",
        [4] = "This reset (Wed-to-Wed)",
        [5] = "This month",
        [6] = "All the time",
    }
end