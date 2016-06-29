--[[ Filtration menu ]]--

----------------------------------------
--[[ description:
  -- Filtration menu.
  -- Фильтрационное меню.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  LF context,
  Rh Utils, Grids.
  -- group: Menus.
  -- areas: any.
--]]
----------------------------------------
--[[ based on:
  searchmenu
  (Searchable Menu.)
  (c) 2009+, maxfl.
  Mail: gmaxfl@gmail.com
  (c) 2009+, Shmuel Zeigerman.
--]]
--------------------------------------------------------------------------------

local type = type
local ipairs, pairs = ipairs, pairs
local require, pcall = require, pcall
local setmetatable = setmetatable

----------------------------------------
--local win, far = win, far

----------------------------------------
--local context = context
local logShow = context.ShowInfo

local tables = require 'context.utils.useTables'

----------------------------------------
--local farUt = require "Rh_Scripts.Utils.Utils"
local menUt = require "Rh_Scripts.Utils.Menu"

----------------------------------------
local fkeys = require "far2.keynames"

local InputRecordToName = fkeys.InputRecordToName

local keyUt = require "Rh_Scripts.Utils.Keys"

local isVKeyChar = keyUt.isVKeyChar
local IsModAlt, IsModShift = keyUt.IsModAlt, keyUt.IsModShift

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Internal
local RunMenu = require "Rh_Scripts.RectMenu.RectMenu"

---------------------------------------- Keys
-- Символы спец. клавиш:
local SpecKeyChars = {
  Decimal   = '.',
  Multiply  = '*',
  Add       = '+',
  Subtract  = '-',
  Divide    = '/',
  NumDel    = '%',
} --- SpecKeyChars

---------------------------------------- Checks
local ItemChecks = { -- Проверки на шаблон:

  -- Plain checking text to simple pattern.
  -- Обычная проверка текста на обычный шаблон.
  plain = function (Text, Pattern, Item) --> (pos, end | nil)
    return Text:cfind(Pattern, 1, true)
  end, -- simple

  -- Simple checking text to Lua pattern.
  -- Простая проверка текста на шаблон Lua.
  pattern = function (Text, Pattern, Item)
    local Pattern = Pattern
    if Pattern:sub(-1,-1) == '%' and -- Exclude single escape character
       Pattern:sub(-2,-2) ~= '%' then Pattern = Pattern:sub(1,-2) end
    return Text:cfind(Pattern)
  end, -- pattern

  -- Standard checking pathes, directory and file names to pattern.
  -- Стандартная проверка путей, имён файлов и каталогов на шаблон.
  dos = function (Text, Pattern, Item) -- Using '*' and '?' for text checking:
    local Pattern = Pattern:gsub("%*+", "*") -- Exclude extra asterisks
                    --:gsub("[%p%-+^$&]", "%%%1")-- Escape special characters
                    :gsub("[%p%-%+%^%$%&]", "%%%1")-- Escape special characters
                    :gsub("%%[?*]", {["%?"]=".", ["%*"]=".-"}) -- Use wildcards
    return Text:cfind(Pattern)
  end, -- pattern
} ---

---------------------------------------- Menu class
local TMenu = {
  Guid = win.Uuid("3751918c-5cd0-4b56-8d32-13898f612930"),
}
--local MMenu = { __index = TMenu }

--[[
local tcopy = tables.copy

local function CreateMenu (Properties, Items, BreakKeys) --> (object)
  assert(type(Menus) == 'table')
  local Properties = tcopy(Properties or {}, true, pairs, false)
  local Flags = menUt.HighlightOff(Properties.Flags)
  local Options = Properties.Filter or {}

  local self = {
    Props     = Properties,
    Items     = Items,
    BKeys     = BreakKeys or {},

    Flags     = Flags,
    Count     = #Items,
    Options   = Options,
  } --- self

  return setmetatable(self, MMenu)
end -- CreateMenu

---------------------------------------- Menu making
--]]

-- Making CheckItem function.
-- Сборка функции CheckItem.
local function MakeCheck (CheckItem) --> (func)
  -- 1. Функция без каких-либо проверок:
  if type(CheckItem) == 'function' then return CheckItem end
  local Check -- Функция проверки

  -- 2. Функция с проверкой шаблона на "":
  if type(CheckItem) == 'string' then
    Check = ItemChecks[CheckItem] or ItemChecks.plain
    return function (Text, Pattern, Item) --> (pos, end | nil)
      if Pattern == "" then return end
      return Check(Text:lower(), Pattern, Item)
    end --
  end -- if
  -- type(CheckItem) == 'table' --

  -- 3. Анализ параметров фильтрации:
  local Info = CheckItem
  Check = Info.CheckItem
  local MatchCase = Info.MatchCase
  local Left, Right = Info.Left, Info.Right
  if type(Check) == 'string' then Check = ItemChecks[Check] end
  Check = Check or ItemChecks.plain
  local fixPos = function (p, a, b) if a then return a + p, b + p end end

  -- 4. Функция с применением параметров фильтрации:
  return function (Text, Pattern, Item) --> (pos, end | nil)
    local p, e, s = Info.Pos, Info.End or -1, Info.Sub
    if Pattern == "" then return end
    if s or p then
      if s then
        p, e, s = Text:cfind(s)
        if not s then
          if not p then p, e = Info.Pos, Info.End or -1 end
          if not p then return end
        else
          p, e = Text:cfind(s, 1, true)
        end
      elseif p < 0 then
        p = Text:len() + p + 1
      end
      Text = s or Text:sub(p, e)
    end -- if

    if not MatchCase then Text = Text:lower() end
    Pattern = (Left or "")..Pattern..(Right or "")

    if p then
      return fixPos(p - 1, Check(Text, Pattern, Item))
    end
    return Check(Text, Pattern, Item)
  end, MatchCase --
end -- MakeCheck

-- Get filter name.
-- Получение имени фильтра.
local function GetCheckName (CheckItem) --> (string)
  local Check = CheckItem
  local tp, name = type(Check)
  if tp == 'table' then
    name = Check.Name
    if not name then
      Check = Check.CheckItem
      tp = type(Check)
    end
  end

  return name or tp == 'string' and Check or
                 tp == 'function' and 'function' or 'unknown'
end -- GetCheckName

---------------------------------------- Prepare
-- "Отображение" пунктов меню.
local function MappingItems (Items)
  local Map = {}
  for k, v in ipairs(Items) do
    local Item = { __index = v }
    setmetatable(Item, Item)
    Map[k] = Item
  end -- for
  return Map
end -- MappingItems

---------------------------------------- Menu making

---------------------------------------- main
do
  -- Флаги
  local DoChange = { isUpdate = true }
  local NoChange = { isUpdate = false }

function unit.Menu (Properties, Items, BreakKeys) --| (Menu)

  local Props = tables.copy(Properties, true, pairs, false) -- true
  --local Props = { __index = Properties }; setmetatable(Props, Props)
  Props.Id = Props.Id or TMenu.Guid

  -- Управление флагами.
  Props.Flags = menUt.HighlightOff(Props.Flags)

  -- Управление фильтрацией.
  Props.Filter = Props.Filter or {}
  local Options = Props.Filter

  -- Шаблон для фильтрации.
  Options.Pattern = Options.Pattern or ""
  local Pattern = Options.Pattern

  -- Функция для фильтрации.
  local CheckItem, MatchCase = MakeCheck(Options.CheckItem or "plain")

  -- Надписи для показа информации о фильтрации.
  local CharsText = Options.CharsText or "*[%s]"
  local ItemsText = Options.ItemsText or "(%d / %d)"
  local CheckText = Options.CheckText or "[%s]"
  local ShowCheck = Options.ShowCheck
  local CheckName = GetCheckName(Options.CheckItem)

  Props.Title = Props.Title or "Menu"
  local Title = Props.Title
  -- TODO: М/б, лучше сделать отдельно от titles.
  if not Title:find("%s", 1, true) then
    Title = Title.." "..CharsText
  end

  Props.Bottom = Props.Bottom or ""
  local Bottom = Props.Bottom
  if Bottom == "" then
    Bottom = ItemsText
  elseif not Bottom:find("%d", 1, true) then
    Bottom = Bottom.." "..ItemsText
  end
  if not Bottom:find("%s", 1, true) and ShowCheck then
    Bottom = Bottom.." "..CheckText
  end

  -- Отображение пунктов для фильтрации.
  local MapItems = MappingItems(Items)
  local AllCount = #MapItems -- Число пунктов
  local CurCount = AllCount -- Счётчик пунктов

  -- Обработка отображаемых клавиш.
  local MapKeys = Options.MapKeys
  --logShow({ BreakKeys, MapKeys }, "Keys", 2)
  local function MapKeyPress (Input, SelIndex)
    local SKey = Input.Name or InputRecordToName(Input)

    for k, f in pairs(MapKeys) do
      if SKey == k and type(f) == 'function' then
        --logShow(SKey, hex(FarKey))
        local isOk, s = pcall(f, Pattern)
        if isOk then Pattern = s end
        return isOk
      end
    end
  end -- MapKeyPress

  -- 2.3. Отбор пунктов на совпадение с шаблоном.
  local function PrepareItems (Pattern)
    local n = 0
    for _, v in ipairs(MapItems) do
      local isOk, fpos, fend = pcall(CheckItem, v.text, Pattern, v)
      if isOk then
        if fpos then
          v.dummy = false --nil
          v.RectMenu = v.RectMenu or {}
          v.RectMenu.TextMark = { fpos, fend }
          n = n + 1
        else
          v.dummy = true
          v.RectMenu = nil
        end
      else
        --v.dummy = true
        v.RectMenu = nil
        n = n + 1
      end
    end
    return n
  end -- PrepareItems

  local function PrepAllItems ()
    for _, v in ipairs(MapItems) do
      v.dummy = false --nil
      v.RectMenu = nil
    end -- for
    return AllCount
  end -- PrepAllItems

  local function ApplyFilter ()
    -- Отбор пунктов меню.
    CurCount = Pattern ~= "" and PrepareItems(Pattern) or PrepAllItems()
    -- Формирование надписей.
    Props.Title = Title:format(Pattern)
    Props.Bottom = Bottom:format(CurCount, AllCount, ShowCheck and CheckName)
  end -- ApplyFilter

  local Table, Flags = { Props, MapItems, BreakKeys }

  --local FMod, FKey -- Информация нажатой клавише

  -- Обработчик нажатия клавиши.
  local function KeyPress (Input, SelIndex)
    Props.SelectIndex = SelIndex -- Восстановление выделения!
  -- 2.1. Обработка "отображаемых" клавиш.
    if MapKeys and MapKeyPress(Input, SelIndex) then return Table end
  -- 2.2. Обработка нажатия клавиши.
      -- Предварительный анализ клавиши.
    local VMod, VKey = Input.ControlKeyState, Input.VirtualKeyCode
    if VMod ~= 0 and
       not IsModShift(VMod) and
       not IsModAlt(VMod) then
      return
    end

    local SKey = Input.Name or InputRecordToName(Input)
    local SpecKeyChar = SpecKeyChars[SKey]
    if SKey ~= "BS" and
       not SpecKeyChar and
       not isVKeyChar(VKey) then
      return
    end

      -- Формирование паттерна.
    if SKey == "BS" then
      if Pattern ~= Options.Pattern then
        Pattern = Pattern:sub(1, -2)
        Flags = DoChange
      else
        Flags = NoChange
      end
    else
      local Char = SpecKeyChar or Input.UnicodeChar
      if IsModAlt(VMod) or not MatchCase then
        Char = Char:lower()
      end
      Pattern = Pattern..Char
      Flags = DoChange
    end

    ApplyFilter() -- Применение фильтра.
    --logShow(SelIndex, hex(FKey))
    return Table, Flags
  end -- KeyPress

  -- Назначение обработчика:
  local RM = Props.RectMenu or {}
  Props.RectMenu = RM
  RM.OnKeyPress = KeyPress

  -- Предварительный отбор:
  ApplyFilter() -- для отображения надписей!

  return RunMenu(Props, MapItems, BreakKeys)
end -- Menu

end -- do

--------------------------------------------------------------------------------
return unit.Menu
--------------------------------------------------------------------------------
