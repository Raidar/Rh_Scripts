--[[ LUM for fl_scripts ]]--

----------------------------------------
--[[ description:
  -- LUM for fl_scripts.
  -- LUM для fl_scripts.
--]]
----------------------------------------
--[[ uses:
  LuaFAR,
  fl_scripts,
  Rh utils, LUM.
  -- areas: basic.
--]]
--------------------------------------------------------------------------------

----------------------------------------
local getFileType = context.detect.area.current

----------------------------------------
local farUt = require "Rh_Scripts.Utils.Utils"

----------------------------------------
--[[
local dbg = require "context.utils.useDebugs"
local logShow = dbg.Show
--]]

--------------------------------------------------------------------------------
local function flsUserMenu (args)
  -- 1. Определение "охвата" меню.
    -- Базовое меню для главного меню.
  local BaseName = args[1]
  local Scope = { BaseName = BaseName, args = args }

  --if not BaseName or BaseName ~= "Config" then
    -- Получение информации о текущем файле.
    Scope.FileName = farUt.GetAreaItemName()
    Scope.FileType = getFileType()
  --end

  --logShow(Scope, "Scope")

  -- 2. Задание пути поиска скриптов.
  --local farUt = require "Rh_Scripts.Utils.Utils"
  --farUt.AddLibPath("", os.getenv("LUA_CPATH") or "")

  -- 3. Вызов пользовательского меню.
  local LUM = require "Rh_Scripts.LuaUM.LUM"
  local Config = require "Rh_Scripts.flsLUM.flsLUMer"
  Config.Scope = Scope

  return LUM(Config)
end -- flsUserMenu

--return flsUserMenu(...)
return farUt.usercall(nil, flsUserMenu, ...)
--------------------------------------------------------------------------------
