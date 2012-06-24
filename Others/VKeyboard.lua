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

--local numbers = require 'context.utils.useNumbers'

----------------------------------------
--local luaUt = require "Rh_Scripts.Utils.luaUtils"
--local farUt = require "Rh_Scripts.Utils.farUtils"
--local keyUt = require "Rh_Scripts.Utils.keyUtils"
--local menUt = require "Rh_Scripts.Utils.menUtils"

----------------------------------------
--[[
local hex = numbers.hex8

local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
--module (...)

--------------------------------------------------------------------------------
--[[ Internal code ]]--[[ Внутренний код ]]--

--[[ Internal code ]]--[[ Внутренний код ]]--
--------------------------------------------------------------------------------
--[[ Menu class ]]--[[ Класс меню ]]--

local TMenu = {} -- Класс меню
local MMenu = { __index = TMenu }

-- Создание объекта класса меню.
local function CreateMenu (Properties, Items, BreakKeys) --> (object)
  local Properties = Properties or {}
  local Options = Properties.VirKey or {}
  local self = {
    Props = Properties,
    Items = Items,
    BKeys = BreakKeys,

    Count = #Items,
    Options = Options,
  } --- self

  return setmetatable(self, MMenu)
end -- CreateMenu

--[[ Menu class ]]--[[ Класс меню ]]--
--------------------------------------------------------------------------------
--[[ Menu making ]]--[[ Формирование меню ]]--


--[[ Menu making ]]--[[ Формирование меню ]]--
--------------------------------------------------------------------------------

local function Menu (Properties, Items, BreakKeys, ShowMenu)
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
return Menu
--------------------------------------------------------------------------------
