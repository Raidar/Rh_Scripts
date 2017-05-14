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

--local slen = unicode.utf8.len
--local slen = unicode.grapheme.len

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local tables = require 'context.utils.useTables'
local numbers = require 'context.utils.useNumbers'
--local strings = require 'context.utils.useStrings'

local Null = tables.Null

local max2, min2 = numbers.max2, numbers.min2
--local divf = numbers.divf

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"

local far_Text = far.Text
--local far_Text, farVText = far.Text, farUt.VText

----------------------------------------
local menUt = require "Rh_Scripts.Utils.Menu"

local RepChar = menUt.RepChar

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Draw text

-- Вывод текста с ограничением по длине.
local function DrawText (Rect, Color, Text) --> (number)

  local Len = min2(Text:len(), Rect.w) -- Длина выведенного текста
  --local Len = min2(slen(Text), Rect.w) -- Длина выведенного текста
  far_Text(Rect.x, Rect.y, Color, Text:sub(1, Len) or "")

  return Len

end -- DrawText
unit.DrawText = DrawText

-- Вывод заполнителя текста.
local function DrawClear (Rect, Color, Spacing) --> (number)

  return DrawText(Rect, Color, -- Пустое место:
                  RepChar("spacing", Spacing, Rect.w))

end -- DrawClear
unit.DrawClear = DrawClear

-- Вывод текста с заполнением по длине.
local function DrawLineText (Rect, Color, Text, Spacing) --> (bool)

  local Len = DrawText(Rect, Color, Text)
  if Len >= Rect.w then return false end

  far_Text(Rect.x + Len, Rect.y, Color,
           RepChar("spacing", Spacing, Rect.w - Len))

  return true

end ---- DrawLineText
unit.DrawLineText = DrawLineText

-- Вывод текста в прямоугольнике.
function unit.DrawRectText (Rect, Color, Text, Spacing, ...) --> (number)

  Color = Rect.Color or Color

  local tp = type(Text)
  local k, Count = 1, Rect.h

  if     tp == 'string' then
    if Text:sub(-1, 1) ~= "\n" then
      Text = Text.."\n"

    end

    for s in Text:gmatch("([^\n]*)\n") do
      if k > Count then break end
      DrawLineText(Rect, Color, s, Spacing)
      k = k + 1
      Rect.y = Rect.y + 1

    end

  elseif tp == 'table' then
    for i = 1, Count do
    --for i = 1, Count or Text.Count or #Text do
    --  if k > Count then break end

      local s = Text[i]
      if type(s) == "function" then
        s = s(k, Rect, ...)

      end

      if s then
        DrawLineText(Rect, Rect.Color or Color, s, Spacing)

      end

      k = k + 1
      Rect.y = Rect.y + 1

    end -- for

  elseif tp == 'function' then
    for i = 1, Count do
      local s = Text(i, Rect, ...)
      if s then
        DrawLineText(Rect, Rect.Color or Color, s, Spacing)

      end

      Rect.y = Rect.y + 1

    end -- for

    return true

  end -- if

  for _ = k + 1, Count do
    DrawClear(Rect, Color, Spacing)
    Rect.y = Rect.y + 1

  end

  return true

end ---- DrawRectText

-- Draw text for non-item of menu.
-- Рисование текста не пункта меню.
function unit.DrawClearItemText (Rect, Color, Spacing)

  -- TODO: MultiLine.
  -- TODO: No one Line but Rect!!!
  return DrawClear(Rect, Color, Spacing)

  -- Пустое место
  --return DrawText(Rect, Color, RepChar("spacing", Spacing, Rect.w)

end ---- DrawClearItemText

-- Рисование текста пункта-разделителя.
function unit.DrawSeparItemText (Rect, Color, Text, Separator)

  local Width = Rect.w
  --local Separ = Separ:sub(1, Width) -- Строка-разделитель
  local Separ = RepChar("separator", Separator, Width)

  -- TODO: MultiLine with text & line alignment.
  if Text and Text ~= "" then
    -- Разделитель с текстом:
    local Len = Text:len()
    if Width > Len then
      local SepLen = bshr(Width - Len, 1)
      --local SepLen = divf(Width - Len, 2)
      Text = Separ:sub(1, SepLen)..Text..
             Separ:sub(1, Width - SepLen - Len)
      --logShow({ Rect, Text, Text:len(), }, Len, 2)

    else
      -- Без разделителя?!

    end

  else
    -- Разделитель обычный
    Text = Separ

  end

  return DrawText(Rect, Color, Text)

end ---- DrawSeparItemText

---------------------------------------- Parse text
do
-- Parse text to color fragments considering marking.
-- Разбор текста на цветовые фрагменты с учётом маркировки.
local function MakeParseText (Item, Color, TextB, TextH, TextE) --> (table)

  local Mark = Item.RectMenu.TextMark or Null -- No change!
  --if #Mark > 0 then logShow(Mark, "Mark info") end
  local MarkB, MarkE

  if type(Mark) == 'table' then
    if type(Mark[1]) == 'string' then
      if Mark[1] ~= "" then
        MarkB, MarkE = (TextB..TextH..TextE):cfind(Mark[1], Mark[2], Mark[3])

      end

    else
      MarkB, MarkE = Mark[1], Mark[2]

    end

  elseif Mark == true then
    MarkB, MarkE = 1, (TextB..TextH..TextE):len()

  end
  --if MarkB then logShow(Mark, "Mark info") end

  MarkB, MarkE = MarkB or 0, MarkE or 0
  if MarkB <= 0 or MarkB > MarkE then
    return {
      0, -- for MarginB
      { text = TextB, color = Color.normal, },
      { text = TextH, color = Color.hlight, },
      { text = TextE, color = Color.normal, },

    } ----

  end

  local t = {
    0, -- for MarginB
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
      t[2].text = TextB:sub(1, MarkB - 1)

    end

    Mark = min2(MarkE, LenB)
    t[3].text = TextB:sub(MarkB, Mark)

    if Mark < LenB then
      t[4].text = TextB:sub(Mark + 1, -1)

    end

  else
    t[2].text = TextB

  end

  Mark = LenB + LenH

  -- Разбор подстроки после &:
  if TextE ~= "" and MarkE > Mark then
    MarkB = max2(MarkB - Mark, 1)
    if MarkB > 1 then
      t[6].text = TextE:sub(1, MarkB - 1)

    end

    Mark = min2(MarkE - Mark, LenE)
    t[7].text = TextE:sub(MarkB, Mark)

    if Mark < LenE then
      t[8].text = TextE:sub(Mark + 1, -1)

    end

  else
    t[8].text = TextE

  end

  --logShow(t, 'Parse Item Text')

  return t

end -- MakeParseText

local checkedChar = menUt.checkedChar

--[[
-- Разбор текста на отдельные линии по символу новой строки.
local function RectParseText (Rect, Color, Parse, Item, Options)

  Item = Item or Null
  local RM, RI = Options.RectMenu, Item.RectMenu or Null
  -- TODO: Fix Padding as in unit.DrawItemText
  --local Padding = RM.ItemPadding ~= false and " " or ""
  local Sign = Options.checked and
               checkedChar(Item.checked,
                           nil,
                           RI.CheckedChar   or RM.CheckedChar,
                           RI.UncheckedChar or RM.UncheckedChar) or false

  local t, n = {}, 1

  local k = 1
  while k <= #Parse do
    local v = Parse[k]

    t[n] = v

    n = n + 1

  end

  return t

end -- RectParseText
--]]

-- Рисование разобранного текста как набора цветовых фрагментов.
local function DrawParseText (Rect, Item, Parse) --> (table)

  local r = { __index = Rect }
  setmetatable(r, r)
  --logShow({ Rect, Parse }, 'Parse Item Text')
  -- TODO: MultiLine with text & line alignment!!!

  for k = Parse.m, Parse.n do
    local v = Parse[k]
    local text = v.text

    if v.newline then -- Новая линия:
      r.x, r.w = nil, nil
      r.y = r.y + 1
      r.h = r.h - 1
      if r.h < 0 then break end

    end

    -- TODO: DrawLineText или Реализовать чистку конца!
    if text and text ~= "" and r.w > 0 then -- Вывод:
      local len = DrawText(r, v.color, text)
      r.x = r.x + len
      r.w = r.w - len
      --if r.w <= 0 then break end -- TODO: Заменить на проверку!!!

    end

  end -- for

  return r

end -- DrawParseText

---------------------------------------- Draw item
local ParseHotStr = farUt.ParseHotStr

-- Рисование текста обычного пункта.
function unit.DrawItemText (Rect, Color, Item, Options)

  --if not Color.marked then logShow({ Item, Rect, Options }, "No color item") end

  Item = Item or Null
  local RM, RI = Options.RectMenu, Item.RectMenu or Null

  -- Разбор текста на части по горячей букве:
  local TextB, TextH, TextE = nil, nil, Item.text
  if Options.isHot then
    TextB, TextH, TextE = ParseHotStr(Item.text, '&')

  end

  TextB, TextH = TextB or "", TextH or ""
  local Len = TextB:len() + TextH:len() + TextE:len() -- Реальная длина
  --local Len = slen(TextB) + slen(TextH) + slen(TextE) -- Реальная длина
  --logShow({ TextB, TextH, TextE }, Len)

  -- Разбор текста с учётом маркировки:
  local Parse = MakeParseText(Item, Color, TextB, TextH, TextE)

  -- Учёт отступов:
  local PaddingL = RM.ItemPadding ~= false and RM.PaddingLChar or ""
  local PaddingR = RM.ItemPadding ~= false and RM.PaddingRChar or ""
  Len = Len + PaddingL:len() + PaddingR:len()

  -- Выравнивание + очистка конца:
  local Clear = Rect.w - Len
  Clear = RepChar("spacing", RI.SpacingChar or RM.SpacingChar, max2(0, Clear))

  -- Учёт начальных и конечных символов:
  Parse.m, Parse.n = 1, #Parse + 1
  if Options.checked then

    --[[
    if Item.checked then
    logShow({ checked   = RI.CheckedChar   or RM.CheckedChar,
              unchecked = RI.UncheckedChar or RM.UncheckedChar}, "Checking")
    end
    --]]

    PaddingL = checkedChar(Item.checked,
                           Item.checked,
                           RI.CheckedChar   or RM.CheckedChar,
                           RI.UncheckedChar or RM.UncheckedChar)..PaddingL
  end

  Parse[1]       = { text = PaddingL,   color = Color.normal, }
  Parse[Parse.n] = { text = Clear..
                            PaddingR,   color = Color.normal, }

  return DrawParseText(Rect, Item, Parse) -- Рисование разобранного текста

end ---- DrawItemText

end -- do
--------------------------------------------------------------------------------
return unit
--------------------------------------------------------------------------------
