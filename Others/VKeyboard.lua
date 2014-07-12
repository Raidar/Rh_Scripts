--[[ Virtual keyboard ]]--
--[[ "Виртуальная клавиатура" ]]--

--[[ uses:
  LuaFAR,
  Rh Utils.
  -- group: Menus.
--]]
--------------------------------------------------------------------------------

--local type = type
--local ipairs, pairs = ipairs, pairs
--local require, pcall = require, pcall
--local setmetatable = setmetatable

----------------------------------------
--local far = far
--local F = far.Flags

----------------------------------------
--local context = context
local logShow = context.ShowInfo

--local numbers = require 'context.utils.useNumbers'

----------------------------------------
--local farUt = require "Rh_Scripts.Utils.Utils"
--local keyUt = require "Rh_Scripts.Utils.Keys"
--local menUt = require "Rh_Scripts.Utils.Menu"

--------------------------------------------------------------------------------
local unit = {}

---------------------------------------- Internal

---------------------------------------- Menu class
local TMenu = {}
local MMenu = { __index = TMenu }

local function CreateMenu (Properties, Items, BreakKeys) --> (object)
  local Properties = Properties or {}
  local Options = Properties.Input or {}
  local self = {
    Props     = Properties,
    Items     = Items,
    BKeys     = BreakKeys,

    Count     = #Items,
    Options   = Options,
  } --- self

  return setmetatable(self, MMenu)
end -- CreateMenu

---------------------------------------- Menu making

function unit.Menu (Properties, Items, BreakKeys, ShowMenu)
                          --| (Menu) and/or --> (Menu|Items)
  if not Items then return end

--[[ 1. Конфигурирование меню ]]
  local _Menu = CreateMenu(Properties, Items, BreakKeys)

  --_Menu:()

--[[ 2. Управление меню ]]

  if ShowMenu == 'self' then return _Menu end

  if ShowMenu == nil then
    return ShowMenu(Properties, Items, BreakKeys)
  end

  return Items
end -- Menu

--------------------------------------------------------------------------------
return unit.Menu
--------------------------------------------------------------------------------
