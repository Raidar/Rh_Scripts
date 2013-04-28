--[[ Dfm Utf8 View ]]--

----------------------------------------
--[[ description:
  -- Просмотр Utf8-текста из dfm-файла Delphi 6-7.
  -- Viewer of Utf8-text from dfm-file for Delphi 6-7.
--]]
----------------------------------------
--[[ uses:
  LuaFAR.
  -- group: Samples.
--]]
--------------------------------------------------------------------------------
local _G = _G

local tonumber = tonumber

local tconcat = table.concat

----------------------------------------
local strings = require 'context.utils.useStrings'

local u8char = strings.u8char

--------------------------------------------------------------------------------
local unit = {}

function unit.DfmUtf8ToAnsi (s) --> (string)
  local Len = s:len()

  local t = {}
  local k, d = 1, ""
  while k <= Len do
    local c = s:sub(k, k)

    if c == '#' then
      local p = k + 1
      while s:sub(p, p):match("%d") and p <= Len do
        p = p + 1
      end
      local d = tonumber(s:sub(k + 1, p - 1))
      if d then
        t[#t + 1] = u8char(d)
      end
      k = p

    elseif c == "'" then
      local p = k + 1
      while s:sub(p, p):match("[^%']") and p <= Len do
        p = p + 1
      end
      t[#t + 1] = s:sub(k + 1, p - 1)
      k = p + 1

    else
      k = k + 1
    end
  end

  return tconcat(t)
end -- DfmUtf8ToAnsi

do
  local farMsg = far.Message
  local DfmUtf8ToAnsi = unit.DfmUtf8ToAnsi

function unit.Show ()
  local Utf8Text = far.PasteFromClipboard()
  --far.Message(Utf8Text, "Utf8-text")

  return farMsg(DfmUtf8ToAnsi(Utf8Text), "Ansi-text")
end ---- Show

end -- do
--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
