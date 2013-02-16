--[[ DateTime Info ]]--

----------------------------------------
--[[ description:
  -- Show date/time information.
  -- Показ информации о дате/времени.
--]]
----------------------------------------
--[[ uses:
  LuaFAR.
  -- group: Samples.
--]]
--------------------------------------------------------------------------------

----------------------------------------
local datim = require "Rh_Scripts.Utils.DateTime"

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]
--------------------------------------------------------------------------------
local Info = {}
local SepLine = "─────────────────────"
local DateFmt = "%04d-%02d-%02d"
local TimeFmt = "%02d:%02d:%02d"

local dt = os.date("*t")

--logShow(dt, "os.date")
Info[#Info+1] = "────── os.date ──────"
Info[#Info+1] = (DateFmt.." "..TimeFmt):format(
                 dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec)
Info[#Info+1] = ("Day of week =   %1d"):format(dt.wday - 1)
Info[#Info+1] = ("Day of year = %03d"):format(dt.yday)

local d = datim.newDate(dt.year, dt.month, dt.day)
--logShow(d, "TDate", "w")
--local d = datim.newDate(1886, 12, 25) -- Check yester year
--local d = datim.newDate(2036, 12, 25) -- Check future year
--local d = datim.newDate(2000, 12, 31) -- Check end of year

local c = d.config
local YearDay   = c:getYearDay(d.y, d.m, d.d)
local EraDay    = c:getEraDay(d.y, d.m, d.d)
local EraMonth  = c:getEraMonth(d.y, d.m)

Info[#Info+1] = "────── TConfig ──────"
Info[#Info+1] = "isLeapYear  = "..tostring(c:isLeapYear(d.y))
Info[#Info+1] = "getLeapDays = "..("%1d"):format(c:getLeapDays(d.y))
Info[#Info+1] = "getYearDay  = "..("%03d"):format(YearDay)
Info[#Info+1] = "divYearDay  = "..DateFmt:format(d.y, c:divYearDay(d.y, YearDay))
Info[#Info+1] = "getYearWeek = "..(" %02d"):format(c:getYearWeek(d.y, d.m, d.d))
Info[#Info+1] = "getWeekDay  = "..("  %1d"):format(c:getWeekDay(d.y, d.m, d.d))
Info[#Info+1] = "getEraDay   = "..("%d"):format(EraDay)
Info[#Info+1] = "divEraDay   = "..DateFmt:format(c:divEraDay(EraDay))
Info[#Info+1] = "getEraMonth = "..("%d"):format(EraMonth)
Info[#Info+1] = "divEraMonth = "..("%04d-%02d"):format(c:divEraMonth(EraMonth))
Info[#Info+1] = SepLine

local t = datim.newTime(dt.hour, dt.min, dt.sec)
--logShow(t, "TTime", "w")

far.Show(unpack(Info))
--------------------------------------------------------------------------------
