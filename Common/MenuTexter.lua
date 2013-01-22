--[[ Menu text-maker ]]--

----------------------------------------
--[[ description:
  -- Text-maker for menu.
  -- Формирователь текста для меню.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: Menus.
  -- areas: any.
--]]
--------------------------------------------------------------------------------

local type = type
local setmetatable = setmetatable

----------------------------------------
local far = far
local F = far.Flags

----------------------------------------
--local context = context

local utils = require 'context.utils.useUtils'
local numbers = require 'context.utils.useNumbers'
local strings = require 'context.utils.useStrings'

local spaces = strings.spaces -- for text align

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"
--local keyUt = require "Rh_Scripts.Utils.Keys"
local menUt = require "Rh_Scripts.Utils.Menu"

----------------------------------------
--[[
local hex = numbers.hex8
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Internal
-- Признаки меню в тексте пункта
-- (символы появления подменю)
unit.MenuLSign = ""
--MenuLSign = "◄ "
unit.MenuRSign = " ►"
unit.SKeySepar = " "
--unit.SKeySepar = "|"

---------------------------------------- Menu class
local TMenu = {} -- Класс меню
local MMenu = { __index = TMenu }

-- Создание объекта класса меню.
local function CreateMenu (Properties, Items) --> (object)
  local Properties = Properties or {}
  local Options = Properties.Texter or {}
  local Flags = Properties.Flags
  --logShow(Properties.Flags, "Flags")

  local self = {
    Props = Properties,
    Items = Items,

    Flags = Flags,
    Count = #Items,
    Options = Options,

    isHot = utils.isFlag(Flags, F.FMENU_SHOWAMPERSAND),
  } --- self

  return setmetatable(self, MMenu)
end -- CreateMenu

---------------------------------------- Menu making
-- Check for submenus availability.
-- Проверка на наличие пунктов-подменю.
function TMenu:hasSubMenu ()
  local Items = self.Items
  for i = 1, self.Count do
    if Items[i].Kind == "Menu" then return true end
  end
end ----

-- Check for multicolumn RectMenu.
-- Проверка на многоколоночное RectMenu.
function TMenu:isFullRectMenu ()
  local RM = self.Props.RectMenu
  if not RM then return false end
  return RM.Rows and RM.Rows == 0 or
         RM.Cols and RM.Cols ~= 1
end ----

do
  local ClearHotText = farUt.ClearHotText

-- Define caption of item.
-- Определение заголовка пункта.
function TMenu:DefineItemCaption (Item) --| (Item)
  if Item.Caption then
    if not Item.Captext then
      Item.Captext = Item.Caption
    end
    return
  end

  if Item.text then -- TEMP: До ввода шаблонов!!
    Item.Captext = Item.Captext or Item.text             -- Исключение:
    Item.Caption = Item.text:gsub("^&.%s%-%s(.+)", "%1") -- "&<A> - "
    Item.Caption = ClearHotText(Item.Caption, '&')       -- ненужных '&'
    --[[
    logShow({ Item.Title, Item.Caption, Item.text,
              Item.text:gsub("^&.%s%-%s(.+)", "%1") }, i)
    --]]
  else
    Item.Caption = Item.Name or ""
    Item.Captext = Item.Captext or Item.Caption
  end
end ---- DefineItemCaption

-- Define captions of menu items for handling.
-- Определение заголовков пунктов меню для обработки.
function TMenu:DefineCaption () --| (self.Items)
  local Menu = self.Items

  for i = 1, self.Count do
    self:DefineItemCaption(Menu[i])
  end
end ----

end -- do

do
  local max2, divf = numbers.max2, numbers.divf
  local ClearHotText = farUt.ClearHotText
  local FieldMax = menUt.FieldMax

-- Определение текста пунктов (с учётом всего меню).
function TMenu:DefineText () --| (self.Items) -- TODO: Шаблон для вывода!!
  local Menu, Options = self.Items, self.Options

  local MenuLSign, MenuRSign, SKeySepar =
        unit.MenuLSign, unit.MenuRSign, unit.SKeySepar

  --logShow(Menu, "Menu", 1)
  --logShow(Options, "Menu Options")
  local textMax = 0 -- Макс. длина текста пунктов меню
  local skeyMax = 0 -- Макс. длина названий клавиш пунктов меню
  local captMax = 0 -- Макс. длина надписей в меню

  -- 1. Расчёт максимальной длины текста. -- Caption пунктов меню:
  local textLen = function (Item, i, k)
    local textStr = Item.Captext -- Длина надписи
    if self.isHot then textStr = ClearHotText(textStr, '&') end
    return textStr:len()
  end-- function textLen
  textMax = FieldMax(Menu, self.Count, nil, textLen)
  --logShow(textMax, "textMax")

  -- 2. Учёт комбинаций клавиш в тексте пункта.
  if Options.TextNamedKeys then -- Макс. длина комбинаций клавиш
    skeyMax = FieldMax(Menu, self.Count, nil, "AccelStr")
    textMax = textMax + skeyMax
    --logShow({ textMax, skeyMax }, "Max")
  end

  -- 3. Выравнивание текста пунктов меню.
     -- Поправка на подменю.
  local hasSubMenu = self:hasSubMenu()
  -- Текст для выравнивания обычных пунктов:
  local LSpace = hasSubMenu and spaces[MenuLSign:len()] or ""

     -- Поправка на надписи в меню.
  if not self:isFullRectMenu() then -- TODO: Change for Grid/Rect support!
    captMax = self.Props.Title:len() -- Расчёт поправки
    if Options.BottomHotKeys then
      captMax = max2(captMax, self.Props.Bottom:len())
    end
    captMax = captMax + 2 -- Учёт рамки окна на краях
  end

  local LAlign = "" -- Текст центрирования
  if Options.CaptAlignText then -- Разница длин текста и надписи
    local captDif = captMax - textMax -- с учётом длины знаков подменю
    if hasSubMenu then
      captDif = captDif - MenuLSign:len() - MenuRSign:len()
    end
    if captDif > 0 then -- Учёт поправки:
      local captSep = divf(captDif, 2)
      LAlign = spaces[captSep] -- Центрирование
      textMax = textMax + captDif - captSep -- Поправка на надписи
    end
  else
    textMax = max2(textMax, captMax)
  end

  -- 4. Формирование текста пунктов меню.
  for i = 1, self.Count do
    local Item = Menu[i]
    local ItemIsMenu = Item.Kind == "Menu"

    -- Учёт комбинаций клавиш.
    local KeyName -- Название комбо-клавиши
    local KeyAlign, RAlign = "" -- Выравнивание комбо-клавиши
    if Options.TextNamedKeys then -- Выравнивание названия комбо-клавиши
      KeyName = Item.AccelStr ~= "" and Item.AccelStr or ""
      if KeyName ~= "" then KeyAlign = SKeySepar
      elseif ItemIsMenu then KeyAlign = spaces[SKeySepar:len()] end
      RAlign = spaces[skeyMax - KeyName:len()]

      if Options.KeysAlignText then
        KeyAlign = KeyAlign..RAlign..KeyName
      elseif ItemIsMenu or KeyName ~= "" then
        KeyAlign = KeyAlign..KeyName..RAlign
      end
    end

    -- Длина текста пункта (без учёта "&").
    local textLen = ClearHotText(Item.Captext, '&'):len()

    -- Выравнивание частей текста пункта.
    -- TODO: Учесть RectMenu !!! (только как, чтобы было независимо от него?!)
    KeyAlign = spaces[textMax - textLen - skeyMax]..KeyAlign
    --logShow({ "'"..Item.Captext.."'", "'"..(Item.text or "").."'" }, "Item")
    if ItemIsMenu then -- Подменю
      Item.text = MenuLSign..LAlign..Item.Captext..KeyAlign..MenuRSign
    elseif Item.Kind ~= "Separator" then -- Не подменю и не разделитель
      Item.text = LAlign..Item.Captext
      if Options.TextNamedKeys and KeyName ~= "" then
        Item.text = Item.text..KeyAlign
      end
      -- Выравнивание при наличии пунктов-подменю:
      if hasSubMenu then Item.text = LSpace..(Item.text or "") end
    end
  end
  --logShow({ textMax - skeyMax, skeyMax }, "2 + ")
end ---- DefineMenuText

end -- do

---------------------------------------- main

function unit.Menu (Properties, Items, BreakKeys, ShowMenu)
                          --| (Menu) and/or --> (Menu|Items)
  if not Items then return end

--[[ 1. Конфигурирование меню ]]
  local _Menu = CreateMenu(Properties, Items)

  _Menu:DefineCaption()
  _Menu:DefineText()

--[[ 2. Управление меню ]]

  local ShowMenu = ShowMenu == nil and far.Menu or ShowMenu

  if ShowMenu == 'self' then return _Menu end

  if ShowMenu and type(ShowMenu) == 'function' then
    return ShowMenu(Properties, Items, BreakKeys)
  end

  return Items
end -- Menu

--------------------------------------------------------------------------------
return unit.Menu
--------------------------------------------------------------------------------
