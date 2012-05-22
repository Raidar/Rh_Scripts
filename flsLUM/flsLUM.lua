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
local _G = _G

local farUt = require "Rh_Scripts.Utils.farUtils"

----------------------------------------
local getFileType = context.detect.area.current

----------------------------------------
--local logMsg = (require "Rh_Scripts.Utils.Logging").Message

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

  --logMsg(Scope, "Scope")

  -- 2. Задание пути поиска скриптов.
  --local extUt = require "Rh_Scripts.Utils.extUtils"
  --extUt.AddLibPath("", os.getenv("LUA_CPATH") or "")

  -- 3. Вызов пользовательского меню.
  local LUM = require "Rh_Scripts.LuaUM.LUM"
  local Config = require "Rh_Scripts.flsLUM.flsLUMer"
  Config.Scope = Scope
  return LUM(Config)
end ---- flsUserMenu

--return flsUserMenu(...)
return farUt.usercall(nil, flsUserMenu, ...)
--------------------------------------------------------------------------------
