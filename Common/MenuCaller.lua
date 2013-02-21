--[[ Menu caller ]]--

----------------------------------------
--[[ description:
  -- Caller of menu with chosen kind.
  -- Вызыватель меню выбранного вида.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: Menus.
  -- areas: any.
--]]
--------------------------------------------------------------------------------

local require = require
local setmetatable = setmetatable

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Internal
local MenuScripts = { -- Скрипты с меню:
  SearchMenu = "far2.searchmenu",               -- "Поисковое" меню
  RectMenu   = "Rh_Scripts.RectMenu.RectMenu",  -- Прямоугольное меню
  FilterMenu = "Rh_Scripts.Common.FilterMenu",  -- Фильтрационное меню
  MenuTexter = "Rh_Scripts.Common.MenuTexter",  -- Формирователь текста для меню
  --VKeyboard  = "Rh_Scripts.Common.VKeyboard",   -- "Виртуальная клавиатура"
} --- MenuScripts

---------------------------------------- Menu class
local TMenu = {} -- Класс меню
local MMenu = { __index = TMenu }

-- Создание объекта класса меню.
local function CreateMenu (Properties)--, Items) --> (object)
  local Properties = Properties or {}
  local Options = Properties.Caller or {}

  local self = {
    Options   = Options,
    Require   = Options.Require or require,
    Call      = Options.Call,
    Kind      = Options.Kind or Properties.MenuView,

    Run       = false, -- Вид запускаемого меню
  } --- self

  return setmetatable(self, MMenu)
end -- CreateMenu

---------------------------------------- Menu making
do
  local far_Menu = far.Menu

-- Определение вида запускаемого меню.
function TMenu:DefineKind () --| (self.ShowMenu)
  local Script = MenuScripts[self.Kind]
  -- Загрузка скрипта меню или использование стандартного меню.
  self.Run = Script and self.Require(Script) or far_Menu
end ----

end -- do
---------------------------------------- main

function unit.Menu (Properties, Items, BreakKeys, ShowMenu)
                    --| (Menu) and/or --> (Menu|Items)
  if not Items or not Items[1] then return end

  local _Menu = CreateMenu(Properties)--, Items)
  if not _Menu then return end

  _Menu:DefineKind()
  --logShow(_Menu, "MenuCaller", 1)

  -- Вывод меню / Возврат самого меню
  if not _Menu.Call then
    return _Menu.Run(Properties, Items, BreakKeys, ShowMenu)
  end

  return _Menu.Call(_Menu.Run, Properties, Items, BreakKeys, ShowMenu)
end ---- Menu

--------------------------------------------------------------------------------
return unit.Menu
--------------------------------------------------------------------------------
