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

local lib = LibStub:NewLibrary("DateUtils-1.0", 1)

if (not lib) then return end

function lib:dateIsToday(source, resetToMidnight)
    local today = getDate(0, resetToMidnight)

    return date("*t", source).yday == today.yday
end

function lib:dateIsYesterday(source, resetToMidnight)
  local yesterday = getDate(-1, resetToMidnight)

  return date("*t", source).yday == yesterday.yday
end

function lib:dateIsInCurrentMonth(source, resetToMidnight)
    local today = getDate(0, resetToMidnight)

    return date("*t", source).month == today.month
end

function lib:dateInRangeTillToday(source, fromDate)
  return (source >= time(fromDate) and date("*t", source).yday <= getDate(0, false).yday)
end

function lib:getToday()
  return getDate(0)
end

function lib:getLastWed(todayWday)
  local wday = todayWday or lib:getToday().wday
  local lastWed = (wday > 4) and (wday - 4) or (wday + 3)
  local lastWedDate = getDate(-lastWed, true)

  return lastWedDate
end

function lib:isWed(wday)
  return wday == 4
end

function getDate(addDays, resetToMidnight)
    local curDate = date('*t')
    curDate.day = curDate.day + addDays
    curDate.isdst = nil

    if (resetToMidnight) then
        curDate.hour = 0
        curDate.min = 0
        curDate.sec = 0
    end

    local newDate = date("*t", time(curDate))

    return newDate
end