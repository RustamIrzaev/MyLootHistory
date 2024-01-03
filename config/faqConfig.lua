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

MLH.groupFaq = {
    type = 'group',
    order = 43,
    name = 'FAQ',
    args = {
        headerWhat = {
            type = 'header',
            name = 'What is this addon for?',
            order = 1,
        },
        textWhat = {
            type = 'description',
            order = 2,
            name = 'The addon that track everything you looted and show you the report with the gathered data. This is useful for the gold farming, for example, to track how much gold you got during the farm session. Or to track how many items you got from the specific zone, etc.'
        },
        headerSorting = {
            type = 'header',
            order = 10,
            name = 'Sorting and filtering',
        },
        textSorting = {
            type = 'description',
            order = 11,
            name = 'Everything can be filtered by a date and by a quality.\n\n'..
                '* Items quality can be filtered by a specific quality (\'Exact quality checkbox\') or by a quality range (for example, from Uncommon and further).\n'..
                '* Dates can be filtered by a specific date or by a date range. For example, \'Today\' or \'This month\'. \n\n'..
                'Sorting is made by descending order by default.\n'
        },
        headerLinking = {
            type = 'header',
            order = 20,
            name = 'Can I link the item from the report?',
        },
        textLinking = {
            type = 'description',
            order = 21,
            name = 'Yes, you can. Just Shift+click on the item icon and it will be linked to the chat. The chat should be opened.'
        },
        headerRestrictions = {
            type = 'header',
            order = 40,
            name = 'Any known restrictions?',
        },
        textRestrictions = {
            type = 'description',
            order = 41,
            name = 'As for now, the addon can\'t track upgraded items (the items that has been upgraded during the looting).'
        },
    }
}