--[[ RectMenu ]]--

----------------------------------------
--[[ description:
  -- RectMenu: Drawing a menu.
  -- RectMenu: Рисование меню.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: RectMenu.
--]]
--------------------------------------------------------------------------------

local type = type
local require = require
local setmetatable = setmetatable

----------------------------------------
local bit = bit64
local bshr = bit.rshift

----------------------------------------
--local context = context

local tables = require 'context.utils.useTables'
local numbers = require 'context.utils.useNumbers'
local strings = require 'context.utils.useStrings'

local Null = tables.Null

local max2, min2 = numbers.max2, numbers.min2
--local divf = numbers.divf

local spaces = strings.spaces -- for text align

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"

local far_Text = far.Text
--local far_Text, farVText = far.Text, farUt.VText

----------------------------------------
local menUt = require "Rh_Scripts.Utils.Menu"

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Draw text

-- Вывод текста с ограничением по длине.
local function LineText (Rect, Color, Text) --> (number)
  local Len = min2(Text:len(), Rect.w) -- Длина выведенного текста
  far_Text(Rect.x, Rect.y, Color, Text:sub(1, Len) or "")

  return Len
end ---- LineText
unit.LineText = LineText

-- Вывод текста с заполнением по длине.
function unit.LineFill (Rect, Color, Text) --> (bool)
  local Len = LineText(Rect, Color, Text)
  if Len >= Rect.w then return false end

  far_Text(Rect.x + Len, Rect.y, Color, spaces[Rect.w - Len + 1])

  return true
end ---- LineFill

-- Draw text for non-item of menu.
-- Рисование текста не пункта меню.
function unit.DrawClearItemText (Rect, Color)
  -- TODO: MultiLine.
  -- TODO: No one Line but Rect!!!
  return LineText(Rect, Color, spaces[Rect.w]) -- Пустое место
end ---- DrawClearItemText

local Separ = ("─"):rep(255) -- Текст-разделитель
--logShow(Separ, "'─': # = "..tostring( Separ:len() ))

-- Рисование текста пункта-разделителя.
function unit.DrawSeparItemText (Rect, Color, Text)
  local Width = Rect.w
  local Separ = Separ:sub(1, Width) -- Строка-разделитель

  -- TODO: MultiLine with text & line alignment.
  if Text and Text ~= "" then
    local Len = Text:len() -- Разделитель с текстом:
    if Width > Len then
      local SepLen = bshr(Width - Len, 1)
      --local SepLen = divf(Width - Len, 2)
      --logShow(Rect, Len, 2)
      LineText(Rect, Color, Separ:sub(1, SepLen)..Text..
                            Separ:sub(1, Width - SepLen - Len))
    else
      LineText(Rect, Color, Text) -- Без разделителя?!
    end
  else
    LineText(Rect, Color, Separ) -- Разделитель обычный
  end
end ---- DrawSeparItemText

---------------------------------------- Parse text
do
-- Parse text to color fragments considering marking.
-- Разбор текста на цветовые фрагменты с учётом маркировки.
local function MakeParseText (Item, Color, TextB, TextH, TextE) --> (table)
  local Mark = Item.RectMenu.TextMark or Null -- No change!
  --if #Mark > 0 then logShow(Mark, "Mark info") end
  local MarkB, MarkE

  if type(Mark[1]) == 'string' then
    if Mark[1] ~= "" then
      MarkB, MarkE = (TextB..TextH..TextE):cfind(Mark[1], Mark[2], Mark[3])
    end
  else
    MarkB, MarkE = Mark[1], Mark[2]
  end
  --if MarkB then logShow(Mark, "Mark info") end

  MarkB, MarkE = MarkB or 0, MarkE or 0
  if MarkB <= 0 or MarkB > MarkE then
    return {
      0, -- for prefix
      { text = TextB, color = Color.normal, },
      { text = TextH, color = Color.hlight, },
      { text = TextE, color = Color.normal, },
    } ----
  end

  local t = {
    0, -- for prefix
    { text = "",    color = Color.normal, },
    { text = "",    color = Color.marked, },
    { text = "",    color = Color.normal, },
    { text = TextH, color = Color.hlight, },
    { text = "",    color = Color.normal, },
    { text = "",    color = Color.marked, },
    { text = "",    color = Color.normal, },
  } --- t
  local LenB, LenH, LenE = TextB:len(), TextH:len(), TextE:len()

  -- Разбор подстроки перед &:
  if TextB ~= "" and MarkB <= LenB then
    if MarkB > 1 then
    t[2].text = TextB:sub(1, MarkB-1) end
    Mark = min2(MarkE, LenB)
    t[3].text = TextB:sub(MarkB, Mark)
    if Mark < LenB then
    t[4].text = TextB:sub(Mark+1, -1) end
  else
    t[2].text = TextB
  end

  Mark = LenB + LenH

  -- Разбор подстроки после &:
  if TextE ~= "" and MarkE > Mark then
    MarkB = max2(MarkB - Mark, 1)
    if MarkB > 1 then
    t[6].text = TextE:sub(1, MarkB-1) end
    Mark = min2(MarkE - Mark, LenE)
    t[7].text = TextE:sub(MarkB, Mark)
    if Mark < LenE then
    t[8].text = TextE:sub(Mark+1, -1) end
  else
    t[8].text = TextE
  end

  --logShow(t, 'Parse Item Text')

  return t
end -- MakeParseText

local checkedChar = menUt.checkedChar

-- [[
-- Разбор текста на отдельные линии по символу новой строки.
local function LineParseText (Rect, Color, Parse, Item, Options)
  local Parse = Parse

  local RM = Options.Props
  local Margin = RM.CompactText and "" or " "
  local Sign = Options.checked and
               checkedChar(Item.checked, RM.CheckedChar, RM.UncheckedChar) or false

  local t, n = {}, 1

  local k = 1
  while k <= #Parse do
    local v = Parse[k]
    
    t[n] = v

    n = n + 1
  end

  return t
end -- LineParseText
--]]

-- Рисование разобранного текста как набора цветовых фрагментов.
local function DrawParseText (Rect, Item, Parse) --> (table)
  local text, len
  local r = { __index = Rect }
  setmetatable(r, r)
  --logShow({ Rect, Parse }, 'Parse Item Text')
  -- TODO: MultiLine with text & line alignment!!!

  local v
  for k = Parse.m, Parse.n do
    v = Parse[k]
    text = v.text

    if v.newline then -- Новая линия:
      r.x, r.w = nil, nil
      r.y = r.y + 1
      r.h = r.h - 1
      if r.h < 0 then break end
    end

    if text and text ~= "" and r.w > 0 then -- Вывод:
      len = LineText(r, v.color, text)
      r.x = r.x + len
      r.w = r.w - len
      --if r.w <= 0 then break end -- TODO: Заменить на проверку!!!
    end
  end

  return r
end -- DrawParseText

---------------------------------------- Draw item
local ParseHotText = farUt.ParseHotText

-- Рисование текста обычного пункта.
function unit.DrawItemText (Rect, Color, Item, Options)
  --if not Color.marked then logShow({ Item, Rect, Options }, "No color item") end
  local RM = Options.Props
  --local RM, RI_Props = Options.Props, Item.RectMenu

  -- Разбор текста на части по горячей букве:
  local TextB, TextH, TextE = nil, nil, Item.text
  if Options.isHot then
    TextB, TextH, TextE = ParseHotText(Item.text, '&')
  end
  TextB, TextH = TextB or "", TextH or ""
  local Len = TextB:len() + TextH:len() + TextE:len() -- Реальная длина
  --logShow({ TextB, TextH, TextE }, Len)

  -- Разбор текста с учётом маркировки:
  local Parse = MakeParseText(Item, Color, TextB, TextH, TextE)
  local Margin = RM.CompactText and "" or " "

  -- Выравнивание + очистка конца:
  local Clear = Rect.w - Len - Margin:len() * 2
  Clear = spaces[max2(0, Clear)]

  -- Учёт начальных и конечных символов:
  Parse.m, Parse.n = 1, #Parse + 1
  local MarginB = Margin
  if Options.checked then
    MarginB = checkedChar(Item.checked, RM.CheckedChar, RM.UncheckedChar)..MarginB
  end
  Parse[1]       = { text = MarginB,       color = Color.normal, }
  Parse[Parse.n] = { text = Clear..Margin, color = Color.normal, }

  DrawParseText(Rect, Item, Parse) -- Рисование разобранного текста
end ---- DrawItemText

end -- do
--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
