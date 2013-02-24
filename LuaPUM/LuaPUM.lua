--[[ LUM for Panels ]]--

----------------------------------------
--[[ description:
  -- LUM for Panels.
  -- LUM для панелей.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  Rh Utils, LUM.
  -- areas: panels.
--]]
--------------------------------------------------------------------------------

----------------------------------------
local logShow = context.ShowInfo

local getFileType = context.detect.area.panels

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"

--------------------------------------------------------------------------------
local function LuaUserMenu (args)
  -- 1. Определение "охвата" меню.
    -- Базовое меню для главного меню.
  local BaseName = args[1]
  local Scope = { BaseName = BaseName, args = args }

  if not BaseName or BaseName ~= "Config" then
    -- Информация об элементе на активной панели:
    local Item = panel.GetCurrentPanelItem(nil, 1)
    Scope.WorkItem = Item -- Текущий элемент активной панели
    local Name = Item and Item.FileName or ".." -- имя
    --logShow(Item, "Current Item Info", 1)
    Scope.FileName = panel.GetPanelDirectory(nil, 1).Name.."\\"..Name
    Scope.FileType = getFileType()
    -- Функция вставки шаблона для панелей
    Scope.InsertText = farUt.FarInsertText.panels
  end

  -- 2. Вызов пользовательского меню.
  --local LUM = require "Rh_Scripts.LuaUM.LUM"
  local LUM = farUt.urequire "Rh_Scripts.LuaUM.LUM"
  local Config = require "Rh_Scripts.LuaPUM.LuaPUMer"
  Config.Scope = Scope

  return LUM(Config)
end -- LuaUserMenu

--return LuaUserMenu(...)
return farUt.usercall(nil, LuaUserMenu, ...)
--------------------------------------------------------------------------------
